module PetriTester

  # Execution chains are used to execute some set of transitions in paths
  # leading to the target @transition.
  # The most common scenario: running a transition requires it to be enabled.
  # Execution chain lets you find a way to make it enabled and eventually fired.
  class ExecutionChain
    include Enumerable

    # @param node [Petri::Node]
    def initialize(transition)
      @transition = transition
      @call_priorities = {}
    end

    # Chain is an array of transitions sorted by execution priority
    # @example [[t1, t2], [t3]]
    # @return [Array<Array<Petri::Transition>>]
    def chain
      @chain ||= build_chain
    end

    def each(&block)
      chain.each(&block)
    end

    private

    def build_chain
      [].tap do |transitions_in_path|
        find_enabling_transitions(@transition, transitions_in_path)
        transitions_in_path.reverse!

        passed_transitions = []
        transitions_in_path.each do |subsequence|
          subsequence.reject! { |transition| passed_transitions.include?(transition) }
          passed_transitions.concat(subsequence)
        end

        transitions_in_path.each do |subsequence|
          subsequence.sort_by! { |transition| @call_priorities[transition] || Float::INFINITY }
        end
      end
    end

    protected

    def find_enabling_transitions(transition, transitions_in_path, index: 0)
      return if transitions_in_path.include?(transition) # handle circular paths

      current_path = (transitions_in_path[index] ||= [])
      current_path << transition unless current_path.include?(transition)

      # Pick a transition on the shortest path which fills input places with tokens
      input_places = transition.input_places

      transitions = input_places.map do |p|
        p.reset_transitions.each do |transition|
          @call_priorities[transition] ||= 0
          @call_priorities[transition] -= 1
          reset_transitions = (transition.output_places & input_places).flat_map(&:reset_transitions)
          @call_priorities[transition] += reset_transitions.count
        end

        arc = p.input_arcs.min_by { |arc| arc[:distance_weight] || Float::INFINITY }

        if arc && arc[:distance_weight] # handle blind nodes
          arc.from_node
        end
      end.compact

      transitions.each do |t|
        if transition != t
          find_enabling_transitions(t, transitions_in_path, index: index + 1)
        end
      end
    end
  end
end
