module Petri
  class Transition < Node

    # @return [String, nil]
    def action
      @data[:action].presence
    end

    def automated?
      @data[:automated].present?
    end

    def input_places
      input_nodes
    end

    def output_places
      output_nodes
    end

    # @return [Array<Place>]
    def places_to_reset
      reset_arcs.map(&:to_node)
    end

    private

    # @return [Array<Arc>]
    def reset_arcs
      net.arcs.select { |arc| arc.from_node == self && arc.reset? }
    end

    # Executes reset arc logic on fire
    def reset_places!
      places_to_reset.each do |place|
        net.reset_tokens(place)
      end
    end

    def consume_tokens!
      input_places.each do |place|
        net.remove_token(place)
      end
    end

    def produce_tokens!
      output_places.each do |place|
        net.put_token(place)
      end
    end
  end
end
