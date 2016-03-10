describe 'flows initialization' do
  it 'loads user flow' do
    Flows['user'].class.must_equal Petri::Net
  end
end
