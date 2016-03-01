describe PetriTester::Runner do
  subject { PetriTester::Runner.new(net) }

  describe '#execute' do
    describe 'reachable transition' do
      let(:net) { load_net('reproduction') }
      let(:human) { Human.create }

      before do
        subject.on('Finish school') { human.finish_school! }
      end

      it 'performs binded action' do
        subject.execute('Finish school')
        human.finished_school?.must_equal true
      end

      it 'enables ouput transitions' do
        next_transition = subject.transition_by_identifier!('Graduate university')
        next_transition.enabled?.must_equal false

        subject.execute('Finish school')

        next_transition.enabled?.must_equal true
      end
    end

    describe 'unreachable transition' do
      let(:net) { load_net('unreachable_transition') }

      it 'raises error' do
        error = assert_raises(ArgumentError) { subject.execute('Unreachable') }
        error.message.must_match /'Unreachable' is unreachable/i
      end
    end
  end
end
