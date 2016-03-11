describe PetriTester::Runner do
  subject { PetriTester::Runner.new(net) }

  describe '#transition_enabled?' do
    describe 'enabled with no color' do
      let(:net) { load_net('colors') }

      before do
        subject.init

        subject.produce('Repaint in red') do |token|
          token['color'] = 'red'
        end

        subject.on('Filter black color') do |action|
          action.consumed_tokens.all? do |token|
            token['color'] == 'black'
          end
        end

        subject.on('Pick black color') do |action|
          action.consumed_tokens.all? do |token|
            token['color'] == 'black'
          end
        end

        subject.on('Pick green color') do
          raise 'Must never be green'
        end
      end

      it 'works with colors' do
        subject.execute!('Paint', {'color' => 'black'})
        subject.transition_enabled?('Pick black color').must_equal true
        subject.transition_enabled?('Pick black color', color: {'color' => 'black'}).must_equal true
        subject.transition_enabled?('Pick black color', color: {'color' => 'red'}).must_equal false
        subject.transition_enabled?('Pick green color', color: {'color' => 'black'}).must_equal false
        subject.transition_enabled?('Pick green color', color: {'color' => 'green'}).must_equal false
        subject.transition_enabled?('Pick green color', color: {'color' => 'red'}).must_equal true
        subject.execute!('Pick black color', {}, color: {'color' => 'black'})
        subject.transition_enabled?('Pick black color').must_equal false
        subject.transition_enabled?('Pick black color', color: {'color' => 'black'}).must_equal false
        subject.transition_enabled?('Pick black color', color: {'color' => 'red'}).must_equal false
      end

      it 'passes params to token data' do
        subject.execute!('Paint', {'color' => 'light gray'})
        subject.transition_enabled?('Pick black color').must_equal false
      end
    end
  end

  describe '#execute' do
    describe 'reachable transition' do
      let(:net) { load_net('reproduction') }
      let(:human) { Human.create }

      before do
        subject.init
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

    describe 'automated actions' do
      let(:net) { load_net('automated_action') }

      before { subject.init }

      it 'moves tokens automatically' do
        subject.tokens.map(&:place).map(&:identifier).sort.must_equal %w(finish)
      end
    end

    describe 'multiple flows' do
      let(:net) { load_net('multiple_flows') }

      it 'enables second flow' do
        subject.execute!('1')
        subject.tokens.map(&:place).map(&:identifier).sort.must_equal %w(passed passed)
        subject.execute!('2')
        subject.tokens.map(&:place).map(&:identifier).sort.must_equal %w(finished passed)
      end

      it 'disables connected flow' do
        subject.execute!('4')
        subject.tokens.map(&:place).map(&:identifier).sort.must_equal %w(after4)
        error = assert_raises(ArgumentError) { subject.execute!('2') }
        error.message.must_match /'2' is not enabled/i
      end
    end

    describe 'tokens data passing' do
      let(:net) { load_net('tokens_data_passing') }

      before do
        subject.produce('Number') do |token|
          token['number'] = token.production_rule.to_i
        end

        subject.produce('Sum') do |token, action|
          token['number'] = action.consumed_tokens.sum { |t| t.data['number'].to_i }
        end

        subject.on('<') do |action|
          if action.output_places.many?
            raise ArgumentError, "Action '<' must have only single output"
          end

          output_arc = action.output_places.first.input_arcs.first
          number = output_arc.production_rule.to_i

          action.consumed_tokens.all? do |token|
            token['number'] < number
          end
        end

        subject.on('>=') do |action|
          if action.output_places.many?
            raise ArgumentError, "Action '>=' must have only single output"
          end

          output_arc = action.output_places.first.input_arcs.first
          number = output_arc.production_rule.to_i

          action.consumed_tokens.all? do |token|
            token['number'] >= number
          end
        end
      end

      let(:result_data) { subject.tokens_at('sum').first.data }

      it 'produces tokens with filled in data' do
        subject.execute!('Sum')
        result_data['number'].must_equal 3
      end

      it 'works with conditionals returning false' do
        subject.execute!('<')
        subject.tokens.map(&:place).map(&:identifier).sort.must_equal %w(sum)
      end

      it 'works with conditionals returning true' do
        subject.execute!('>=')
        subject.tokens.map(&:place).map(&:identifier).sort.must_equal %w(finish)
      end
    end

    describe 'big user flow' do
      let(:net) { load_net('user') }

      it 'works' do
        subject.init
        subject.execute!('Create profile')
      end
    end
  end
end
