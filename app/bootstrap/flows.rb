class Flows
  class << self
    def [](flow_name)
      all[flow_name.to_s]
    end

    def all
      @all ||= {}
    end

    def load(flow_name)
      all[flow_name.to_s] = Petri::Net.from_string(read_flow("#{flow_name}.bpf"))
    end

    # @param file_name [String]
    # @return [String]
    def read_flow(file_name)
      File.new(Framework.root.join('app', 'flows', file_name)).read
    end
  end
end

Flows.load('user')
