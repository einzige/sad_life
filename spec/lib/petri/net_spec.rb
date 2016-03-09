describe Petri::Net do
  it 'works' do
    Petri::Net.new
  end

  describe '.from_string' do
    subject { load_net('from_place_to_transition') }

    it 'loads places' do
      subject.places.count.must_equal 1
      place = subject.places[0]
      place.identifier.must_equal 'place'
    end

    it 'loads transitions' do
      subject.transitions.count.must_equal 1
      transition = subject.transitions[0]
      transition.identifier.must_equal 'Transition'
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

  describe '#start_place' do
    subject { load_net('single_start_place') }

    it 'returns start_place' do
      subject.start_place.identifier.must_equal 'start place'
    end

    describe 'multiple start places' do
      subject { load_net('firing') }

      it 'raises error' do
        assert_raises ArgumentError do
          subject.start_place
        end
      end
    end

    describe 'no start places' do
      subject { load_net('join_and') }

      it 'raises error' do
        assert_raises ArgumentError do
          subject.start_place
        end
      end
    end
  end

  describe '#node_by_identifier' do
    subject { load_net('from_place_to_transition') }

    it 'finds matched place' do
      subject.node_by_identifier('place').class.must_equal Petri::Place
    end

    it 'finds matched transition' do
      subject.node_by_identifier('Transition').class.must_equal Petri::Transition
    end

    specify do
      subject.node_by_identifier('blah').must_equal nil
    end
  end
end
