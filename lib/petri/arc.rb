module Petri
  class Arc < Element
    attr_reader :from_node
    attr_reader :to_node

    def initialize(net, from: nil, to: nil)
      super(net)
      @from_node = from
      @to_node = to
    end
  end
end
