module Petri
  module NetLoader
    extend ActiveSupport::Concern

    # @param guid [String]
    # @param identifier [String]
    # @param start [true, false]
    def add_place(guid: , identifier: , start: , finish: )
      @places << Place.new(self, {guid: guid, identifier: identifier, start: start, finish: finish})
    end

    # @param guid [String]
    # @param identifier [String]
    # @param action [String]
    def add_transition(guid: , identifier: , action: , automated: )
      @transitions << Transition.new(self, {guid: guid, identifier: identifier, action: action, automated: automated})
    end

    # @param guid [String]
    # @param identifier [String]
    # @param from_guid [String]
    # @param to_guid [String]
    # @param type [String]
    # @param production_rule [String, nil]
    def add_arc(guid: , from_guid: , to_guid: , type: , production_rule: nil, guard: nil)
      from_node = node_by_guid(from_guid)
      to_node = node_by_guid(to_guid)
      @arcs << Arc.new(self, from: from_node, to: to_node, type: type.try(:to_sym), guid: guid, production_rule: production_rule, guard: guard)
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
                          identifier: data['identifier'],
                          start: data['start'],
                          finish: data['finish'])
          end

          hash['transitions'].each do |data|
            net.add_transition(guid: data['guid'],
                               identifier: data['identifier'],
                               automated: data['automated'],
                               action: data['action'])
          end

          hash['arcs'].each do |data|
            net.add_arc(guid: data['guid'],
                        from_guid: data['from_guid'],
                        to_guid: data['to_guid'],
                        type: data['type'],
                        production_rule: data['production_rule'],
                        guard: data['guard'])
          end
        end
      end
    end
  end
end
