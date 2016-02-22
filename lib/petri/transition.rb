module Petri
  class Transition < Node

    # @return [String, nil]
    def action
      @data[:action].presence
    end

    def enabled?
      input_places.all?(&:has_token?)
    end

    def fire!
      raise ArgumentError, 'Transition is not enabled' unless enabled?
      consume_tokens
      callback.try(:call)
      produce_tokens
    end

    # @param block [Proc]
    def set_callback(&block)
      @callback = block
    end

    # @return [Proc, nil]
    def callback
      @callback
    end

    private

    def consume_tokens
      input_places.each do |place|
        net.remove_token(place)
      end
    end

    def produce_tokens
      output_places.each do |place|
        net.put_token(place)
      end
    end

    # @return [Array<Arc>]
    def input_arcs
      net.arcs.select { |arc| arc.to_node == self }
    end

    # @return [Array<Place>]
    def input_places
      input_arcs.map(&:from_node)
    end

    # @return [Array<Arc>]
    def output_arcs
      net.arcs.select { |arc| arc.from_node == self }
    end

    # @return [Array<Place>]
    def output_places
      output_arcs.map(&:to_node)
    end
  end
end
