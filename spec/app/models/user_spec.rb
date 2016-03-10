describe User do
  subject { User.new }

  it 'initializes flow properly' do
    subject.has_profile?.must_equal false
    subject.can_create_profile?.must_equal false
    subject.account_active?.must_equal false
    subject.init_flow
    subject.account_active?.must_equal true
    subject.can_create_profile?.must_equal true
    subject.has_profile?.must_equal false
    subject.create_profile
    subject.has_profile?.must_equal true
  end
end
