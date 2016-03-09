module Petri
  class Net
    include NetLoader

    attr_reader :places, :transitions, :arcs

    def initialize
      @transitions = []
      @places = []
      @arcs = []
      @data = {}
    end

    # @return [Place]
    def start_place
      start_places = @places.select(&:start?).select do |place|
        place.identifier.blank? ||
          places_by_identifier(place.identifier).select(&:finish?).empty?
      end

      raise ArgumentError, 'There are more than one start places' if start_places.many?
      raise ArgumentError, 'There is no start place' if start_places.empty?

      start_places.first
    end

    # @param identifier [String]
    # @return [Node, nil]
    def node_by_identifier(identifier)
      identifier = identifier.to_s
      @places.each { |node| return node if node.identifier == identifier }
      @transitions.each { |node| return node if node.identifier == identifier }
      nil
    end

    def [](key)
      @data[key]
    end

    def []=(k, v)
      @data[k] = v
    end

    protected

    def node_by_guid(guid)
      @places.each { |node| return node if node.guid == guid }
      @transitions.each { |node| return node if node.guid == guid }
      nil
    end

    # @param identifier [String]
    # @return [Array<Place>]
    def places_by_identifier(identifier)
      identifier = identifier.to_s
      @places.select { |node| node.identifier == identifier }
    end
  end
end
