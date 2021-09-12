module DeviseRequestSpecLogin
  include Warden::Test::Helpers

  def self.included(base)
    base.before(:each) { Warden.test_mode! }
    base.after(:each) { Warden.test_reset! }
  end

  # Call within a test (it block) or before(:each) { login_admin }
  def login_admin
    login(:admin_user)
  end

  def login_user
    login(:user)
  end

  # The name of this method can't be "logout", or else it overrides the Devise
  # method with the same name.
  def logout_example
    logout(warden_scope(@current_user))
  end

  private

  def login(user_factory_name)
    # The user is created in an instance variable to be accessible from
    # anywhere in the spec files.
    @current_user = FactoryBot.create(user_factory_name)
    # Required if using the "confirmable" module
    @current_user.confirm
    login_as(@current_user, scope: warden_scope(@current_user))
  end

  def warden_scope(resource)
    resource.class.name.underscore.to_sym
  end
end
