module Petri
  class Transition < Node

    # @return [String, nil]
    def action
      @data[:action]
    end

    def enabled?
      incoming_places.all?(&:has_token?)
    end

    private

    # @return [Array<Arc>]
    def incoming_arcs
      net.arcs.select { |arc| arc.to_node == self }
    end

    # @return [Array<Place>]
    def incoming_places
      incoming_arcs.map(&:from_node)
    end
  end
end
