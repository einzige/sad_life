class CreateDocumentPost < BaseAction

  def perform
    @user.documents_count = 0
  end

  def produce(token)
    token['post_id'] = 1234
  end
end
