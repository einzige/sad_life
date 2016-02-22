describe PetriTester::DistanceWeightIndexator do
  describe '#reindex' do
    subject { load_net('weights') }

    before do
      PetriTester::DistanceWeightIndexator.new(subject).reindex
    end

    it 'measures distance to the start place' do
      subject.start_place.output_arcs.map { |a| a[:distance_weight] }.must_equal [0, 0, 0]
      subject.arcs.map { |a| a[:distance_weight] }.sort.must_equal [0, 0, 0, 1, 1, 1, 1, 1]
    end

    describe 'multiple paths through a single arc' do
      subject { load_net('weights2') }

      it 'sets minimal weight' do
        arc = subject.arcs.find { |arc| arc.guid == 'c54ba3c0-d983-11e5-a7b6-0d487dccd14c' }
        arc[:distance_weight].must_equal 3
      end
    end

    describe 'multiple paths through a single arc #2' do
      subject { load_net('weights3') }

      it 'sets minimal weight' do
        arc = subject.arcs.find { |arc| arc.guid == 'c3441e80-d984-11e5-a7b6-0d487dccd14c' }
        arc[:distance_weight].must_equal 2
      end
    end
  end
end
