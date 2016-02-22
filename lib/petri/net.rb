module Petri
  class Net
    include NetLoader

    attr_reader :places, :transitions, :arcs, :tokens

    def initialize
      @transitions = []
      @places = []
      @arcs = []
      @tokens = []
    end

    # Lets the process be started
    # Populates tokens in start places
    def init
      places.each do |place|
        put_token(place) if place.start?
      end
    end

    # @param place [Place]
    # @return [Token]
    def put_token(place)
      Token.new(place).tap do |token|
        @tokens << token
      end
    end

    protected

    def node_by_guid(guid)
      @places.each { |node| return node if node.guid == guid }
      @transitions.each { |node| return node if node.guid == guid }
      nil
    end
  end
end
