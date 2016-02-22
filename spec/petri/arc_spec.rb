describe Petri::Arc do
  let(:net) { Petri::Net.new }

  subject { Petri::Arc.new(net) }

  it 'assigns net' do
    subject.net.must_equal net
  end
end
