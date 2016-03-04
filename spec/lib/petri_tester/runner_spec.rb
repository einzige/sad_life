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

      it 'enables output transitions' do
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
          token.data['number'] = action.consumed_tokens.sum { |t| t.data['number'].to_i }
        end

        subject.on('<') do |action|
          if action.output_places.many?
            raise ArgumentError, "Action '<' must have only single output"
          end

          output_arc = action.output_places.first.input_arcs.first
          number = output_arc.production_rule.to_i

          action.consumed_tokens.all? do |token|
            token.data['number'] < number
          end
        end

        subject.on('>=') do |action|
          if action.output_places.many?
            raise ArgumentError, "Action '>=' must have only single output"
          end

          output_arc = action.output_places.first.input_arcs.first
          number = output_arc.production_rule.to_i

          action.consumed_tokens.all? do |token|
            token.data['number'] >= number
          end
        end
      end

      let(:result_data) { subject.tokens.first.data }

      it 'produces tokens with filled in data' do
        subject.execute!('Sum', performer_id: @user.id)
        result_data['number'].must_equal 3
      end

      it 'works with conditionals returning false' do
        subject.execute!('<')
        subject.tokens.count.must_equal 1
        subject.tokens.first.place.identifier.must_equal 'sum'
      end

      it 'works with conditionals returning true' do
        subject.execute!('>=')
        subject.tokens.count.must_equal 1
        subject.tokens.first.place.identifier.must_equal 'finish'
      end
    end
  end
end
