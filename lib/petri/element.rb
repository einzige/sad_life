module Petri
  class Element
    attr_reader :net, :data, :guid

    # @param net [Net]
    # @param data [Hash<Symbol>]
    def initialize(net, data = {})
      @net = net
      @data = data.symbolize_keys || {}
      @guid ||= data[:guid] if data[:guid]
    end

    def [](key)
      @data[key]
    end

    def []=(k, v)
      @data[k] = v
    end
  end
end
