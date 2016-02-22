module Petri
  class Node < Element

    # @return [String, nil]
    def title
      @data[:title]
    end
  end
end
