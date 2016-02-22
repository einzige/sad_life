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
  end
end
