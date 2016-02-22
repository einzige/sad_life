module Petri
  class Element
    attr_reader :net

    # @param net [Petri::Net]
    def initialize(net)
      @net = net
    end
  end
end
