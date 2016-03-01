module PetriTester
  class Runner

    # @param net [Petri::Net]
    def initialize(net)
      @net = net
      @callbacks = {}
      @initialized = false
    end

    # Binds callback on a net transition
    # @param transition_identifier [String]
    # @param block [Proc]
    def on(transition_identifier, &block)
      raise ArgumentError, 'No block given' unless block
      @callbacks[transition_by_identifier!(transition_identifier)] = block
    end

    # @param transition_identifier [String]
    def execute(transition_identifier)
      init
      target_transition = transition_by_identifier!(transition_identifier)

      PetriTester::ExecutionChain.new(target_transition).each do |level|
        level.each do |transition|
          unless transition.enabled?
            raise ArgumentError, "Transition '#{transition.identifier}' is unreachable"
          end

          callback = @callbacks[transition]
          callback ? transition.fire!(&callback) : transition.fire!
        end
      end
    end

    # @param identifier [String]
    # @return [Transition, nil]
    def transition_by_identifier(identifier)
      @net.transitions.find { |t| t.identifier == identifier }
    end

    # @param identifier [String]
    # @raise [ArgumentError] if transition is not found
    # @return [Transition]
    def transition_by_identifier!(identifier)
      transition_by_identifier(identifier) or raise ArgumentError, "No such transition '#{identifier}'"
    end

    private

    def init
      return if @initialized

      # Fill start places with tokens to let the process start
      @net.init

      # Without weights assigned transition execution path search won't work
      PetriTester::DistanceWeightIndexator.new(@net).reindex

      @initialized = true
    end
  end
end
