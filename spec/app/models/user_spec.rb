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
    subject.flow.transition_enabled?('Upload document').must_equal true
    subject.flow.transition_enabled?('Delete document').must_equal false
    subject.flow.transition_enabled?('Create document post').must_equal false

    upload_document = UploadDocument.new(subject)
    delete_document = DeleteDocument.new(subject)
    create_document_post = CreateDocumentPost.new(subject)
    update_post = UpdatePost.new(subject)

    subject.flow.on('Upload document') { |action| upload_document.perform!(action) }
    subject.flow.produce('Upload document') { |token| upload_document.produce(token) }
    subject.flow.on('Delete document') { |action| delete_document.perform!(action) }
    subject.flow.produce('Delete document') { |token| delete_document.produce(token) }
    subject.flow.on('Create document post') { |action| create_document_post.perform!(action) }
    subject.flow.produce('Create document post') { |token, action| create_document_post.produce(token) }
    subject.flow.on('Update post') { |action| update_post.perform!(action) }

    subject.flow.on('<=') do |action|
      outgoing_arc = action.outgoing_arcs.first or raise 'Needs an output'
      number = outgoing_arc.production_rule.to_i

      action.consumed_tokens.all? do |token|
        token[action.ingoing_arcs.first.guard] <= number
      end
    end

    subject.flow.on('>=') do |action|
      outgoing_arc = action.outgoing_arcs.first or raise 'Needs an output'
      number = outgoing_arc.production_rule.to_i

      action.consumed_tokens.all? do |token|
        token[action.ingoing_arcs.first.guard] >= number
      end
    end

    subject.flow.execute!('Upload document')

    subject.documents_count.must_equal 1
    subject.flow.transition_enabled?('Upload document').must_equal true
    subject.flow.transition_enabled?('Delete document').must_equal true
    subject.flow.transition_enabled?('Create document post').must_equal true

    subject.flow.execute!('Upload document')

    subject.documents_count.must_equal 2
    subject.flow.transition_enabled?('Upload document').must_equal true

    subject.flow.execute!('Upload document')

    subject.documents_count.must_equal 3
    subject.flow.transition_enabled?('Upload document').must_equal true

    subject.flow.execute!('Upload document')

    subject.documents_count.must_equal 4
    subject.flow.transition_enabled?('Upload document').must_equal true

    subject.flow.execute!('Upload document')

    subject.documents_count.must_equal 5
    subject.flow.transition_enabled?('Upload document').must_equal false

    subject.flow.execute!('Delete document')

    subject.documents_count.must_equal 4
    subject.flow.transition_enabled?('Upload document').must_equal true
    subject.flow.transition_enabled?('Create document post').must_equal true

    subject.flow.execute!('Delete document')

    subject.documents_count.must_equal 3
    subject.flow.transition_enabled?('Upload document').must_equal true
    subject.flow.transition_enabled?('Create document post').must_equal true

    subject.flow.execute!('Delete document')

    subject.documents_count.must_equal 2
    subject.flow.transition_enabled?('Upload document').must_equal true
    subject.flow.transition_enabled?('Create document post').must_equal true

    subject.flow.execute!('Delete document')

    subject.documents_count.must_equal 1
    subject.flow.transition_enabled?('Upload document').must_equal true
    subject.flow.transition_enabled?('Delete document').must_equal true
    subject.flow.transition_enabled?('Create document post').must_equal true

    subject.flow.execute!('Delete document')

    subject.documents_count.must_equal 0
    subject.flow.transition_enabled?('Upload document').must_equal true
    subject.flow.transition_enabled?('Delete document').must_equal false
    subject.flow.transition_enabled?('Create document post').must_equal false

    subject.flow.execute!('Upload document')
    subject.flow.execute!('Upload document')

    subject.documents_count.must_equal 2
    subject.flow.transition_enabled?('Upload document').must_equal true
    subject.flow.transition_enabled?('Delete document').must_equal true
    subject.flow.transition_enabled?('Create document post').must_equal true

    subject.flow.execute!('Create document post')
    subject.documents_count.must_equal 0
    subject.flow.transition_enabled?('Upload document').must_equal true
    subject.flow.transition_enabled?('Delete document').must_equal false
    subject.flow.transition_enabled?('Create document post').must_equal false
    subject.flow.transition_enabled?('Update post').must_equal true

    subject.flow.execute!('Update post')
    subject.post_updated.must_equal true
    subject.flow.transition_enabled?('Update post').must_equal true
    subject.flow.execute!('Lock')
    subject.flow.transition_enabled?('Update post').must_equal false
    subject.flow.execute!('Unlock')
    subject.flow.transition_enabled?('Update post').must_equal true
  end
end
