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
  end
end
