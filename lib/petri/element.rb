module Petri
  class Element
    attr_reader :net

    # @param net [Net]
    def initialize(net)
      @net = net
    end
  end
end
