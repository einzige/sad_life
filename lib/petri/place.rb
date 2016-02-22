module Petri
  class Place < Node

    def has_token?
      net.tokens.any? { |token| token.place == self }
    end

    def start?
      !!@data[:start]
    end
  end
end
