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
        subject.execute!('Finish school')
        human.finished_school?.must_equal true
      end

      it 'enables ouput transitions' do
        next_transition = net.node_by_identifier('Graduate university')
        subject.transition_enabled?(next_transition).must_equal false

        subject.execute!('Finish school')

        subject.transition_enabled?(next_transition).must_equal true
      end
    end

    describe 'unreachable transition' do
      let(:net) { load_net('unreachable_transition') }

      it 'raises error' do
        error = assert_raises(ArgumentError) { subject.execute!('Unreachable') }
        error.message.must_match /'Unreachable' is not enabled/i
      end
    end

    describe 'tokens data passing' do
      let(:net) { load_net('tokens_data_passing') }

      before do
        subject.produce('Number') do |token|
          token.data['number'] = token.production_rule.to_i
        end

        subject.produce('Sum') do |token, action|
          token.data['sum'] = action.consumed_tokens.sum { |t| t.data['number'].to_i }
        end
      end

      let(:result_data) { subject.tokens.first.data }

      it 'produces tokens with filled in data' do
        subject.execute!('Sum')
        result_data['sum'].must_equal 3
      end
    end
  end
end
