module Petri
  class Arc < Element
    attr_reader :from_node, :to_node, :type

    def initialize(net, from: nil, to: nil, type: nil, guid: nil)
      super(net, {guid: guid})
      @from_node = from
      @to_node = to
      @type = type || :regular
    end
  end
end
