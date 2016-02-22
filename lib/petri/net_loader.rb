module Petri
  module NetLoader
    extend ActiveSupport::Concern

    # @param guid [String]
    # @param title [String]
    # @param start [true, false]
    def add_place(guid: , title: , start: )
      @places << Place.new(self, {guid: guid, title: title, start: start})
    end

    # @param guid [String]
    # @param title [String]
    # @param action [String]
    def add_transition(guid: , title: , action: )
      @transitions << Transition.new(self, {guid: guid, title: title, action: action})
    end

    # @param guid [String]
    # @param title [String]
    # @param from_guid [String]
    # @param to_guid [String]
    # @param type [String]
    def add_arc(guid: , from_guid: , to_guid: , type: )
      from_node = node_by_guid(from_guid)
      to_node = node_by_guid(to_guid)
      @arcs << Arc.new(self, from: from_node, to: to_node, type: type.try(:to_sym), guid: guid)
    end

    def node_by_guid(guid)
      @places.each { |node| return node if node.guid == guid }
      @transitions.each { |node| return node if node.guid == guid }
      nil
    end

    module ClassMethods
      # @param path [String]
      # @return [Net]
      def from_file(path)
        from_stream(File.new(path))
      end

      # @param io [IO]
      # @return [Net]
      def from_stream(io)
        from_string(io.read)
      end

      # @param str [String]
      # @return [Net]
      def from_string(str)
        from_hash(JSON.parse(str))
      end

      # @param hash [Hash<String>]
      # @return [Net]
      def from_hash(hash)
        self.new.tap do |net|
          hash['places'].each do |data|
            net.add_place(guid: data['guid'],
                          title: data['title'],
                          start: data['start'])
          end

          hash['transitions'].each do |data|
            net.add_transition(guid: data['guid'],
                               title: data['title'],
                               action: data['action'])
          end

          hash['arcs'].each do |data|
            net.add_arc(guid: data['guid'],
                        from_guid: data['from_guid'],
                        to_guid: data['to_guid'],
                        type: data['type'])
          end
        end
      end
    end
  end
end
