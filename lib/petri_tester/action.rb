module PetriTester
  class Action
    attr_reader :kase, :transition
    attr_reader :consumed_tokens, :produced_tokens

    # @param kase [PetriTester::Runner]
    # @param transition [Petri::Transition]
    def initialize(kase, transition)
      @kase = kase
      @transition = transition
      @consumed_tokens = []
      @produced_tokens = []
    end

    def perform!
      raise ArgumentError, "Transition '#{transition.identifier}' is not enabled" unless kase.transition_enabled?(transition)

      reset_places!
      consume_tokens!
      kase.execution_callbacks[transition].try(:call, self).tap do
        produce_tokens!
      end
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
        kase.remove_token(place)
      end.compact
    end

    def produce_tokens!
      transition.output_places.each do |place|
        produced_tokens << kase.put_token(place, source: transition)

        if production_callback
          produced_tokens.each do |token|
            production_callback.call(token, self)
          end
        end
      end
    end

    def production_callback
      kase.production_callbacks[transition]
    end
  end
end
