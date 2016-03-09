describe Petri::Place do
  let(:net) { Petri::Net.new }

  subject { Petri::Place.new(net) }

  it 'assigns net' do
    subject.net.must_equal net
  end

  describe '#reset_arcs' do
    let(:net) { load_net('reset_arc') }

    specify do
      net.node_by_identifier('reset on produce').reset_arcs.map(&:from_node).must_equal [net.node_by_identifier('Producer')]
      net.node_by_identifier('reset and fill on produce').reset_arcs.map(&:from_node).must_equal [net.node_by_identifier('Producer')]
      net.node_by_identifier('start').reset_arcs.must_equal []
      net.node_by_identifier('finish').reset_arcs.must_equal []
    end
  end

  describe '#reset_transitions' do
    let(:net) { load_net('reset_arc') }

    specify do
      net.node_by_identifier('reset on produce').reset_transitions.must_equal [net.node_by_identifier('Producer')]
      net.node_by_identifier('reset and fill on produce').reset_transitions.must_equal [net.node_by_identifier('Producer')]
      net.node_by_identifier('start').reset_transitions.must_equal []
      net.node_by_identifier('finish').reset_transitions.must_equal []
    end
  end
end
