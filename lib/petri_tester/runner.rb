module PetriTester
  class Runner
    attr_reader :tokens, :execution_callbacks, :production_callbacks

    # @param net [Petri::Net]
    def initialize(net)
      @net = net
      @tokens = []

      @execution_callbacks = {}
      @production_callbacks = {}

      @initialized = false
    end

    # Binds callback on a net transition
    # @param transition_identifier [String]
    # @param block [Proc]
    def on(transition_identifier, &block)
      raise ArgumentError, 'No block given' unless block
      @execution_callbacks[transition_by_identifier!(transition_identifier)] = block
    end

    # Binds producing callback on a net transition
    # @param transition_identifier [String]
    # @param block [Proc]
    def produce(transition_identifier, &block)
      raise ArgumentError, 'No block given' unless block
      @production_callbacks[transition_by_identifier!(transition_identifier)] = block
    end

    # @param transition_identifier [String]
    def execute!(transition_identifier, params = {})
      init
      target_transition = transition_by_identifier!(transition_identifier)

      if transition_enabled?(target_transition)
        perform_action!(target_transition, params)
      else
        PetriTester::ExecutionChain.new(target_transition).each do |level|
          level.each do |transition|
            if transition == target_transition
              perform_action!(transition, params)
            else
              perform_action(transition, params)
            end
          end
        end
      end
    end

    # @param transition [Petri::Transition]
    # @return [true, false]
    def transition_enabled?(transition)
      return false unless @initialized

      has_input_tokens = transition.input_places.all? do |place|
        @tokens.any? { |token| token.place == place }
      end

      has_termination_tokens = @terminators[transition].all? do |termination_place|
        termination_place[:enabled]
      end

      has_input_tokens && has_termination_tokens
    end

    # @param place_identifier [String, Place]
    # @return [true, false]
    def has_token_at?(place_identifier)
      case place_identifier
      when Petri::Place
        place = place_identifier
      when String, Symbol
        place = place_by_identifier!(place_identifier)
      else
        raise ArgumentErrror
      end

      @tokens.any? { |token| token.place == place }
    end

    # @param place_identifier [String]
    def terminated?(place_identifier)
      place = places_by_identifier(place_identifier).select(&:finish?).first
      place or raise ArgumentError, "No such terminator: #{place_identifier}"

      !has_token_at?(place)
    end

    # @param place [Place]
    # @param source [Transition, nil]
    # @return [Token]
    def put_token(place, source: nil)
      Petri::Token.new(place, source).tap do |token|
        @tokens << token

        if place.finish?
          links = @net.places.select { |p| p.start? && p.identifier == place.identifier }

          links.each do |link|
            put_token(link)
            link[:enabled] = true
          end
        end
      end
    end

    # @param place [Place]
    # @return [Token, nil]
    def remove_token(place)
      @tokens.each do |token|
        if token.place == place
          @tokens.delete(token)

          place.links.each do |link|
            remove_token(link)
            link[:enabled] = false
          end

          return token
        end
      end
      nil
    end

    # @param token [Token]
    def restore_token(token)
      @tokens << token
    end

    # @param place [Place]
    # @return [Array<Token>]
    def reset_tokens(place)
      [].tap do |result|
        @tokens.each do |token|
          result << token if token.place == place
        end

        result.each { |token| @tokens.delete(token) }
      end
    end

    # Puts tokens in start places
    # Executes automated actions if any enabled
    # Fills out weights for futher usage
    def init
      return if @initialized

      # Fill start places with tokens to let the process start
      put_token(start_place)
      start_place[:enabled] = true

      # Terminators are used to identify which transitions can be executed
      @terminators = {}
      @net.places.select(&:start?).each do |start_place|
        outgoing_transitions(start_place).each do |transition|
          (@terminators[transition] ||= []) << start_place
        end
      end

      # Without weights assigned transition execution path search won't work
      PetriTester::DistanceWeightIndexator.new(@net).reindex

      @initialized = true
      execute_automated!
    end

    def tokens_at(place_identifier)
      @tokens.select do |token|
        token.place == @net.node_by_identifier(place_identifier)
      end
    end

    private

    def outgoing_nodes(node, nodes = [])
      node.output_nodes.each do |n|
        unless nodes.include?(n)
          outgoing_nodes(n, nodes << n)

          if n.is_a? Petri::Place
            n.links.each do |link|
              outgoing_nodes(link, nodes)
            end
          end
        end
      end

      nodes
    end

    def outgoing_transitions(place)
      outgoing_nodes(place).select { |n| n.is_a? Petri::Transition }
    end

    # Runs all automated transitions which are enabled at the moment
    # @param source [Petri::Transition]
    def execute_automated!(source: nil)
      @net.transitions.each do |transition|
        if transition_enabled?(transition) && transition.automated? && source != transition
          perform_action!(transition)
        end
      end
    end

    # Fires transition if enabled, executes binded block
    # @param transition [Petri::Transition]
    # @param params [Hash]
    def perform_action(transition, *args)
      if transition_enabled?(transition)
        perform_action!(transition)
      end
    end

    # Fires transition, executes binded block
    # @raise
    # @param transition [Petri::Transition]
    # @param params [Hash]
    def perform_action!(transition, params = {})
      Action.new(self, transition, params).perform!.tap do
        execute_automated!(source: transition)
      end
    end

    # @param identifier [String]
    # @raise [ArgumentError] if transition is not found
    # @return [Transition]
    def transition_by_identifier!(identifier)
      @net.node_by_identifier(identifier) or raise ArgumentError, "No such transition '#{identifier}'"
    end

    def place_by_identifier!(identifier)
      @net.place_by_identifier(identifier) or raise ArgumentError, "No such transition '#{identifier}'"
    end

    # @param identifier [String]
    # @return [Array<Petri::Place>]
    def places_by_identifier(identifier)
      identifier = identifier.to_s
      @net.places.select { |node| node.identifier == identifier }
    end

    # @return [Array<Petri::Place>]
    def start_place
      @start_place ||= @net.places.find do |place|
        place.start? && (place.identifier.blank? || places_by_identifier(place.identifier).one?)
      end or raise 'No start place in the net'
    end
  end
end
