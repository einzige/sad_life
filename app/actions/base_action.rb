class BaseAction
  attr_reader :user

  def initialize(user)
    @user = user
  end

  # @note return false for negative result, tokens won't be produced
  # @return [true, false, Object]
  def perform
    raise NotImplementedError
  end

  # Fills token data while populating them in case of #perform succeed
  # @param token [Petri::Token]
  def produce(token)
    raise NotImplementedError
  end
end
