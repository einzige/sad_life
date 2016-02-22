module Petri
  class Node < Element

    # @return [String, nil]
    def title
      @data[:title]
    end

    # @return [Array<Arc>]
    def input_arcs
      net.arcs.select { |arc| arc.to_node == self }
    end

    # @return [Array<Node>]
    def input_nodes
      input_arcs.map(&:from_node)
    end

    # @return [Array<Arc>]
    def output_arcs
      net.arcs.select { |arc| arc.from_node == self }
    end

    # @return [Array<Node>]
    def output_nodes
      output_arcs.map(&:to_node)
    end

    # Fills the graph with arc weights used to find shortest paths
    # @param weight [Integer]
    def index_output_arc_distance_weights(weight = 0)
      output_arcs.each do |arc|
        arc.index_distance_weight(weight)
      end
    end
  end
end
