describe Petri::Arc do
  let(:net) { Petri::Net.new }
  let(:from_node) { Petri::Place.new(net) }
  let(:to_node) { Petri::Transition.new(net) }

  subject { Petri::Arc.new(net, from: from_node, to: to_node) }

  it 'assigns net' do
    subject.net.must_equal net
  end

  it 'assigns from_node' do
    subject.from_node.must_equal from_node
  end

  it 'assigns to_node' do
    subject.to_node.must_equal to_node
  end
end
