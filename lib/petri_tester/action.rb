module PetriTester
  class Action
    attr_reader :kase, :transition, :params
    attr_reader :consumed_tokens, :produced_tokens

    # @param kase [PetriTester::Runner]
    # @param transition [Petri::Transition]
    def initialize(kase, transition, params = {})
      @kase = kase
      @transition = transition
      @consumed_tokens = []
      @produced_tokens = []
      @params = {}
    end

    # @return [true, false]
    def perform!(params = {})
      raise ArgumentError, "Transition '#{transition.identifier}' is not enabled" unless kase.transition_enabled?(transition)

      reset_places!
      consume_tokens!

      if execution_callback
        execution_callback.call(self).tap do |result|
          if result
            produce_tokens!
          else
            unconsume_tokens!
          end
        end
      else
        produce_tokens!
        true
      end
    end

    def output_places
      transition.output_places
    end

    private

    # action :create_profile do |name: , blah: |
    #   User.create(name: name, blah: blah)
    # end
    #
    # def self.action(name, &block)
    #   runner.on(name) do |transition|
    #     user = User.create
    #     transition.produce do |token|
    #       token['id'] = user
    #     end
    #   end
    # end
    #
    # def create_profile(name: , blah: )
    #   execute('create_profile') do
    #     User.create(name: name, blah: blah)
    #   end
    # end

    # def execute(tname, parmas = {})
    #   ActiveRecord::Transaction do
    #     Runner.new(self.net).execute!(tname, parmas.perge({performer_id: performer.id, is_admin: performer.is_admin?}))
    #   end
    # end

    # Executes reset arc logic on fire
    def reset_places!
      transition.places_to_reset.each do |place|
        kase.reset_tokens(place)
      end
    end

    def consume_tokens!
      @consumed_tokens = transition.input_places.map do |place|
        unless place.start?
          kase.remove_token(place).tap do |token|
            token.data.merge!(params)
          end
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

    def execution_callback
      kase.execution_callbacks[transition]
    end
  end
end
