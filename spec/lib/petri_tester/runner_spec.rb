describe PetriTester::Runner do
  let(:net) { load_net('reproduction') }
  let(:human) { Human.create }
  subject { PetriTester::Runner.new(net) }

  describe '#execute' do
    before do
      subject.on('Finish school') { human.finish_school! }
    end

    it 'performs binded action' do
      subject.execute('Finish school')
      human.finished_school?.must_equal true
    end

    it 'enables ouput transitions' do
      next_transition = subject.transition_by_title!('Graduate university')
      next_transition.enabled?.must_equal false

      subject.execute('Finish school')

      next_transition.enabled?.must_equal true
    end
  end
end
