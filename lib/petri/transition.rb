module Petri
  class Transition < Node

    # @return [String, nil]
    def action
      @data[:action]
    end
  end
end
