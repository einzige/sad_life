describe Human do
  subject { Human.create }

  describe '#finished_school' do
    it 'never finished a school' do
      subject.finished_school?.must_equal false
    end
  end
end
