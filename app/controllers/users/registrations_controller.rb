class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: custom_parameters)
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: custom_parameters)
  end

  # The path used after sign up.
  def after_sign_up_path_for(_resource)
    root_path
  end

  # The path used after sign up for inactive accounts (before the e-mail is
  # confirmed). Do not redirect to a path that requires authentication or the
  # flash message asking the user to confirm his e-mail will be lost.
  def after_inactive_sign_up_path_for(_resource)
    new_user_session_path
  end

  private

  def custom_parameters
    # Do NOT include attributes that the user is not supposed to change, such
    # as his own role.
    %i[first_name last_name]
  end
end
