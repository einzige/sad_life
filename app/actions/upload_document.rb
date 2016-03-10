class UploadDocument < BaseAction

  def perform
    @user.documents_count += 1
  end

  def produce(token)
    token['uploads_count'] = @user.documents_count
  end
end
