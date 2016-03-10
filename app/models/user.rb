class User

  attr_reader :profile

  def create_profile
    raise ArgumentError unless can_create_profile?
    @profile = Profile.new(self)
  end

  def has_profile?
    !!@profile
  end

  # @return [PetriTester::Runner]
  def flow
    @runner ||= PetriTester::Runner.new(Flows['user'])
  end

  def init_flow
    flow.init
  end

  def account_active?
    !flow.terminated?('account active')
  end

  def can_create_profile?
    flow.has_token_at?('no profile') && account_active?
  end

  class Profile
    attr_reader :user

    def initialize(user)
      @user = user
    end
  end
end
