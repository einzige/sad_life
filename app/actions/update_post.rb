class UpdatePost < BaseAction

  def perform
    user.post_updated = true
  end

  def produce(token)
    token['post_id'] = 1234
  end
end
