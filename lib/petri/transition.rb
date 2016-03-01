module Petri
  class Transition < Node

    # @return [String, nil]
    def action
      @data[:action].presence
    end

    def enabled?
      input_places.all?(&:has_token?)
    end

    def fire!(&block)
      raise ArgumentError, 'Transition is not enabled' unless enabled?
      reset_places!
      consume_tokens!
      block.try(:call)
      produce_tokens!
    end

    def input_places
      input_nodes
    end

    def output_places
      output_nodes
    end

    private

    # @return [Array<Arc>]
    def reset_arcs
      net.arcs.select { |arc| arc.from_node == self && arc.reset? }
    end

    # @return [Array<Place>]
    def places_to_reset
      reset_arcs.map(&:to_node)
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
