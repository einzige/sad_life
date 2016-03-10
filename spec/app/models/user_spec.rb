describe User do
  subject { User.new }

  it 'initializes flow properly' do
    subject.can_upload_document?.must_equal false
    subject.has_profile?.must_equal false
    subject.can_create_profile?.must_equal false
    subject.account_active?.must_equal false
    subject.init_flow
    subject.account_active?.must_equal true
    subject.can_create_profile?.must_equal true
    subject.has_profile?.must_equal false
    subject.flow.transition_enabled?('Create profile').must_equal true
    subject.can_upload_document?.must_equal false

    subject.flow.on('Create profile') { subject.create_profile }
    subject.flow.execute!('Create profile')

    subject.has_profile?.must_equal true
    subject.can_upload_document?.must_equal true
  end
end
