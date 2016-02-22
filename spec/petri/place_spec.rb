describe Petri::Place do
  let(:net) { Petri::Net.new }

  subject { Petri::Place.new(net) }

  it 'assigns net' do
    subject.net.must_equal net
  end
end
