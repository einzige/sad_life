class User

  attr_reader :profile
  attr_accessor :documents_count

  def initialize
    @documents_count = 0
  end

  def create_profile
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

  def can_upload_document?
    flow.transition_enabled?('Upload document')
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
