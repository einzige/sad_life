module Petri
  class Token
    attr_reader :place

    # @param place [Place]
    def initialize(place)
      @place = place
    end
  end
end
