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
      end.reverse
    end

    protected

    # @note it doesn't handle reset arcs
    def find_enabling_transitions(transition, transitions_in_path, index: 0)
      return if transitions_in_path.include?(transition) # handle circular paths

      current_path = (transitions_in_path[index] ||= [])
      current_path << transition unless current_path.include?(transition)

      # Pick a transition on the shortest path which fills input places with tokens
      transitions = transition.input_places.map do |p|
        arc = p.input_arcs.min_by { |arc| arc[:distance_weight] || Float::INFINITY }
        arc.from_node if arc && arc[:distance_weight] # handle blind nodes
      end.compact

      transitions.each do |transition|
        find_enabling_transitions(transition, transitions_in_path, index: index + 1)
      end
    end
  end
end
