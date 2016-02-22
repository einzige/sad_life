describe Petri::Place do
  let(:net) { Petri::Net.new }

  subject { Petri::Place.new(net) }

  it 'assigns net' do
    subject.net.must_equal net
  end

  describe '#has_token?' do
    it 'returns false' do
      subject.has_token?.must_equal false
    end

    it 'returns true if token present' do
      net.put_token(subject)
      subject.has_token?.must_equal true
    end
  end
end
