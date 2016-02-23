describe PetriTester::ExecutionChain do
  let(:net) { load_net('linear_path') }
  let(:transition) { net.transitions.find { |t| t[:title] == 'C' } }

  describe '#chain' do
    before { PetriTester::DistanceWeightIndexator.new(net).reindex }
    subject { PetriTester::ExecutionChain.new(transition) }

    it 'returns chain of transitions grouped by call priority' do
      subject.chain.count.must_equal 3
      subject.chain[0].map(&:title).must_equal ['A']
      subject.chain[1].map(&:title).must_equal ['B']
      subject.chain[2].map(&:title).must_equal ['C']
    end

    describe 'non linear path' do
      let(:net) { load_net('non_linear_path') }
      let(:transition) { net.transitions.find { |t| t[:title] == 'E' } }

      it 'returns chain of transitions grouped by call priority' do
        subject.chain.count.must_equal 4
        subject.chain[0].map(&:title).must_equal ['A']
        subject.chain[1].map(&:title).must_equal ['B', 'C1', 'D1']
        subject.chain[2].map(&:title).must_equal ['C2', 'D2']
        subject.chain[3].map(&:title).must_equal ['E']
      end
    end
  end
end
