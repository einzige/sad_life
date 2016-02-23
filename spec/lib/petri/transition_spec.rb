describe Petri::Transition do
  let(:net) { Petri::Net.new }

  subject { Petri::Transition.new(net) }

  it 'assigns net' do
    subject.net.must_equal net
  end

  describe '#enabled?' do
    let(:net) { load_net('join_and') }

    subject { net.transitions.first }

    it 'is not enabled' do
      subject.enabled?.must_equal false
    end

    describe 'one place with token' do
      before do
        net.put_token(net.places.first)
      end

      it 'is still not enabled' do
        subject.enabled?.must_equal false
      end
    end

    describe 'all places have at least one token' do
      before do
        net.places.each do |place|
          net.put_token(place)
        end
      end

      it 'makes it enabled' do
        subject.enabled?.must_equal true
      end
    end
  end

  describe '#fire!' do
    let(:net) { load_net('firing') }
    subject { net.transitions.first }

    it 'raises if transition is not enabled' do
      assert_raises ArgumentError do
        subject.fire!
      end
    end

    describe 'enabled transition' do
      before { net.init }

      it 'consumes tokens' do
        input_places = net.places.select(&:start?)
        input_places.all?(&:has_token?).must_equal true

        subject.fire!

        input_places.any?(&:has_token?).must_equal false
      end

      it 'produces token' do
        output_places = net.places.select { |place| !place.start? }
        output_places.any?(&:has_token?).must_equal false

        subject.fire!

        output_places.all?(&:has_token?).must_equal true
      end

      it 'yields' do
        x = false
        subject.fire! { x = true }
        x.must_equal true
      end
    end
  end
end
