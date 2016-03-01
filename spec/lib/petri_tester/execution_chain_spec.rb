describe PetriTester::ExecutionChain do
  let(:net) { load_net('linear_path') }
  let(:transition) { net.transitions.find { |t| t[:identifier] == 'C' } }

  describe '#chain' do
    before { PetriTester::DistanceWeightIndexator.new(net).reindex }
    subject { PetriTester::ExecutionChain.new(transition) }

    it 'returns chain of transitions grouped by call priority' do
      subject.chain.count.must_equal 3
      subject.chain[0].map(&:identifier).must_equal ['A']
      subject.chain[1].map(&:identifier).must_equal ['B']
      subject.chain[2].map(&:identifier).must_equal ['C']
    end

    describe 'non linear path' do
      let(:net) { load_net('non_linear_path') }
      let(:transition) { net.transitions.find { |t| t[:identifier] == 'E' } }

      it 'returns chain of transitions grouped by call priority' do
        subject.chain.count.must_equal 4
        subject.chain[0].map(&:identifier).must_equal ['A']
        subject.chain[1].map(&:identifier).must_equal ['B', 'C1', 'D1']
        subject.chain[2].map(&:identifier).must_equal ['C2', 'D2', 'X1', 'X3']
        subject.chain[3].map(&:identifier).must_equal ['E']
      end
    end

    describe 'conflicting path (with reset arcs which kill the process)' do
      let(:net) { load_net('conflicting_path') }
      let(:transition) { net.node_by_identifier('C') }

      it 'returns chain with proper order so C firing is possible' do
        subject.chain.count.must_equal 2
        subject.chain[0].map(&:identifier).must_equal ['X1', 'B', 'A']
        subject.chain[1].map(&:identifier).must_equal ['C']
      end
    end

    describe 'path to the very first transition in the net' do
      let(:net) { load_net('from_place_to_transition') }
      let(:transition) { net.transitions.first }

      it 'returns transition itself' do
        subject.chain.must_equal [[transition]]
      end
    end
  end
end
