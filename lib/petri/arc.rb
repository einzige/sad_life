module Petri
  class Arc < Element
    attr_reader :from_node, :to_node, :type

    def initialize(net, from: nil, to: nil, type: nil, guid: nil, production_rule: nil)
      super(net, {guid: guid, production_rule: production_rule})
      @from_node = from
      @to_node = to
      @type = type.try(:to_sym) || :regular
    end

    def reset?
      @type == :reset
    end

    def regular?
      @type == :regular
    end
  end
end
