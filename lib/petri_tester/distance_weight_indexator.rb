module PetriTester

  # This class is used to fill metadata on arcs with weights - distances from
  # start node of a net to the arc itself.
  # These weights are used to optimize shortest paths search.
  class DistanceWeightIndexator

    # @param net [Petri::Net]
    def initialize(net)
      @net = net
    end

    def reindex
      reset_weights
      index_from_node(@net.start_place)
    end

    private

    def index_from_node(node, weight: 0)
      node.output_arcs.each do |arc|
        index_from_arc(arc, weight: weight)
      end
    end

    def index_from_arc(arc, weight: 0)
      return if arc[:distance_weight] && arc[:distance_weight] < weight

      arc[:distance_weight] = weight
      index_from_node(arc.to_node, weight: weight + 1)
    end

    def reset_weights
      @net.arcs.each do |arc|
        arc[:distance_weight] = nil
      end
    end
  end
end
