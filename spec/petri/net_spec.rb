describe Petri::Net do
  it 'works' do
    Petri::Net.new
  end

  describe '.from_string' do
    subject { load_net('from_place_to_transition') }

    it 'loads places' do
      subject.places.count.must_equal 1
      place = subject.places[0]
      place.title.must_equal 'place'
    end

    it 'loads transitions' do
      subject.transitions.count.must_equal 1
      transition = subject.transitions[0]
      transition.title.must_equal 'Transition'
      transition.action.must_equal 't'
    end

    it 'loads arcs' do
      subject.arcs.count.must_equal 1
      arc = subject.arcs[0]
      arc.from_node.must_equal subject.places.first
      arc.to_node.must_equal subject.transitions.first
      arc.type.must_equal :regular
    end
  end

  describe '#put_token' do
    subject { Petri::Net.new }
    let(:place) { Petri::Place.new(subject) }

    it 'adds a token' do
      subject.tokens.count.must_equal 0
      subject.put_token(place)
      subject.tokens.count.must_equal 1
      subject.tokens[0].class.must_equal Petri::Token
      subject.tokens[0].place.must_equal place
    end
  end
end
