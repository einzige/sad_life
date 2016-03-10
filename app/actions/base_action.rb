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

  # @param action [PetriTester::Action]
  # @return [true, false]
  def perform!(action)
    action.ingoing_arcs.each do |arc|
      if arc.guard.present?
        next if action.params.key?(arc.guard)

        arc_token = action.consumed_tokens.find do |token|
          token.place == arc.from_node
        end

        arc_token.data.key?(arc.guard) or raise ArgumentError
      end
    end

    perform
  end

  # Fills token data while populating them in case of #perform succeed
  # @param token [Petri::Token]
  # @return [true, false]
  def produce(token)
  end
end
