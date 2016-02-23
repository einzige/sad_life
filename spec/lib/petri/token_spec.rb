describe Petri::Token do
  let(:net) { Petri::Net.new }
  let(:place) { Petri::Place.new(net) }

  subject { Petri::Token.new(place) }

  it 'assigns net' do
    subject.place.must_equal place
  end
end
