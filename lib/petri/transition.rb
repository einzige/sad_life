module Petri
  class Transition < Node

    # @return [String, nil]
    def action
      @data[:action]
    end

    def enabled?
      input_places.all?(&:has_token?)
    end

    private

    # @return [Array<Arc>]
    def input_arcs
      net.arcs.select { |arc| arc.to_node == self }
    end

    # @return [Array<Place>]
    def input_places
      input_arcs.map(&:from_node)
    end
  end
end
