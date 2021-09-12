module DeviseControllerSpecLogin
  # Call within a test (it block) or before(:each) { login_admin }
  def login_admin
    login(:admin_user)
  end

  def login_user
    login(:user)
  end

  def logout
    sign_out @current_user
  end

  private

  def login(user_factory_name)
    # The user is created in an instance variable to be accessible from
    # anywhere in the spec files.
    @current_user = FactoryBot.create(user_factory_name)
    # Required if using the "confirmable" module
    @current_user.confirm
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @current_user
  end
end
