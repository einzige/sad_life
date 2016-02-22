module Petri
  class Arc < Element
    attr_reader :from_node, :to_node, :type

    def initialize(net, from: nil, to: nil, type: nil, guid: nil)
      super(net, {guid: guid})
      @from_node = from
      @to_node = to
      @type = type || :regular
    end

    # Returns distance to start place if net is indexed
    # @return [Integer, nil]
    def distance_weight
      @data[:distance_weight]
    end

    def reset_distance_weight
      @data[:distance_weight] = nil
    end

    # Fills the graph with arc weights used to find shortest paths
    # @param weight [Integer]
    def index_distance_weight(weight)
      return if distance_weight && distance_weight < weight

      @data[:distance_weight] = weight
      to_node.index_output_arc_distance_weights(distance_weight + 1)
    end
  end
end
