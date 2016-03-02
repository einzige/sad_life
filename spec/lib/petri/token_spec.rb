describe Petri::Token do
  let(:net) { Petri::Net.new }
  let(:place) { Petri::Place.new(net) }

  subject { Petri::Token.new(place) }

  it 'assigns net' do
    subject.place.must_equal place
  end

  describe '#source_arc, #production_rule' do
    let(:net) { load_net('tokens_data_passing') }
    let(:transition) { net.node_by_identifier('Number') }
    let(:place_one) { net.node_by_identifier('one') }
    let(:place_two) { net.node_by_identifier('two') }

    let(:token_one) { Petri::Token.new(place_one, transition) }
    let(:token_two) { Petri::Token.new(place_two, transition) }

    it 'returns source arc' do
      token_one.source_arc.data[:production_rule].must_equal "1"
      token_two.source_arc.data[:production_rule].must_equal "2"
    end

    it 'returns production rule' do
      token_one.production_rule.must_equal "1"
      token_two.production_rule.must_equal "2"
    end
  end
end
