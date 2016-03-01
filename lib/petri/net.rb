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

    # @param place [Place]
    # @return [Token, nil]
    def remove_token(place)
      @tokens.each do |token|
        if token.place == place
          @tokens.delete(token)
          return token
        end
      end
      nil
    end

    # @param place [Place]
    # @return [Array<Token>]
    def reset_tokens(place)
      [].tap do |result|
        @tokens.each do |token|
          result << token if token.place == place
        end

        result.each { |token| @tokens.delete(token) }
      end
    end

    # @return [Place]
    def start_place
      start_places = @places.select(&:start?)
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

    protected

    def node_by_guid(guid)
      @places.each { |node| return node if node.guid == guid }
      @transitions.each { |node| return node if node.guid == guid }
      nil
    end
  end
end
