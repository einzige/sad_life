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
      consume_tokens
      block.try(:call)
      produce_tokens
    end

    def input_places
      input_nodes
    end

    def output_places
      output_nodes
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
  end
end
