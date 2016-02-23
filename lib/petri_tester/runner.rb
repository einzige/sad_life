module PetriTester
  class Runner

    # @param net [Petri::Net]
    def initialize(net)
      @net = net
      @callbacks = {}
      @initialized = false
    end

    # Binds callback on a net transition
    # @param transition_title [String]
    # @param block [Proc]
    def on(transition_title, &block)
      raise ArgumentError, 'No block given' unless block
      @callbacks[transition_by_title!(transition_title)] = block
    end

    # @param transition_title [String]
    def execute(transition_title)
      init
      transition = transition_by_title!(transition_title)

      PetriTester::ExecutionChain.new(transition).each do |level|
        level.each do |transition|
          callback = @callbacks[transition]
          callback ? transition.fire!(&callback) : transition.fire!
        end
      end
    end

    # @param title [String]
    # @return [Transition, nil]
    def transition_by_title(title)
      @net.transitions.find { |t| t.title == title }
    end

    # @param title [String]
    # @raise [ArgumentError] if transition is not found
    # @return [Transition]
    def transition_by_title!(title)
      transition_by_title(title) or raise ArgumentError, "No such transition '#{title}'"
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
