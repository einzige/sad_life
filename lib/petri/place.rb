module Petri
  class Place < Node

    def has_token?
      net.tokens.any? { |token| token.place == self }
    end

    def start?
      !!@data[:start]
    end

    def finish?
      !!@data[:finish]
    end

    # @return [Array<Arc>]
    def reset_arcs
      net.arcs.select { |arc| arc.to_node == self && arc.reset? }
    end

    # @return [Array<Transition>[]
    def reset_transitions
      reset_arcs.map(&:from_node)
    end

    def links
      if finish?
        @net.places.select { |place| place.start? && place.identifier == identifier }
      else
        []
      end
    end
  end
end
