describe Petri::Transition do
  let(:net) { Petri::Net.new }

  subject { Petri::Transition.new(net) }

  it 'assigns net' do
    subject.net.must_equal net
  end
end
