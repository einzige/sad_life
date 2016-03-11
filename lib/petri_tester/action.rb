module PetriTester
  class Action
    attr_reader :kase, :transition, :params, :color
    attr_reader :consumed_tokens, :produced_tokens

    # @param kase [PetriTester::Runner]
    # @param transition [Petri::Transition]
    # @param params [Hash]
    # @param color [Hash] Consuming token color
    def initialize(kase, transition, params: {}, color: {})
      @kase = kase
      @color = color
      @transition = transition
      @consumed_tokens = []
      @produced_tokens = []
      @params = params
    end

    # @return [true, false]
    def perform!(params = {})
      unless kase.transition_enabled?(transition, color: color)
        raise ArgumentError, "Transition '#{transition.identifier}' is not enabled"
      end

      consume_tokens!

      if execution_callback
        execution_callback.call(self).tap do |result|
          if result
            reset_places!
            produce_tokens!
          else
            unconsume_tokens!
          end
        end
      else
        reset_places!
        produce_tokens!
        true
      end
    end

    def output_places
      transition.output_places
    end

    def outgoing_arcs
      transition.outgoing_arcs
    end

    def ingoing_arcs
      transition.ingoing_arcs
    end

    private

    # Executes reset arc logic on fire
    def reset_places!
      transition.places_to_reset.each do |place|
        kase.reset_tokens(place)
      end
    end

    def consume_tokens!
      @consumed_tokens = transition.input_places.map do |place|
        kase.remove_token(place, color: color).tap do |token|
          token.data.merge!(params)
        end
      end.compact
    end

    # Executed when action didn't pass through
    def unconsume_tokens!
      consumed_tokens.each do |token|
        kase.restore_token(token)
      end
    end

    def produce_tokens!
      output_places.each do |place|
        token = kase.put_token(place, source: transition)
        token.data.merge!(color)
        token.data.merge!(params)
        production_callback.call(token, self) if production_callback
        produced_tokens << token
      end
    end

    def production_callback
      kase.production_callbacks[transition]
    end

    def execution_callback
      kase.execution_callbacks[transition]
    end
  end
end
