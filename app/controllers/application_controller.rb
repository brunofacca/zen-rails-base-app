# :nodoc:
class ApplicationController < ActionController::Base
  # Authorization gem
  include Pundit

  protect_from_forgery with: :exception

  # Ensure that Pundit's #verify_policy_scoped or #verify_authorized are
  # called in all actions of all controllers. In other words, ensure
  # authorization policies are enforced everywhere.
  after_action :verify_authorized,
               except: :index,
               unless: :devise_controller?
  after_action :verify_policy_scoped,
               only: :index,
               unless: :devise_controller?

  # Require authentication for all requests. Add
  # skip_before_action :authenticate_user! to controllers that should not
  # require authentication.
  before_action :authenticate_user!, unless: :devise_controller?

  # Display user-friendly errors for the following exceptions
  rescue_from Pundit::NotAuthorizedError,
              with: :show_user_not_authorized_error
  rescue_from ActiveRecord::DeleteRestrictionError,
              with: :show_delete_restriction_error

  layout :set_layout

  private

  # Choose from 3 types of layouts: guest (not logged-in), user or admin
  def set_layout
    return 'guest' unless user_signed_in?
    current_user.admin? ? 'admin' : 'user'
  end

  # Rescue Pundit::NotAuthorizedError, which happens when a user tries to
  # access a resource for which he does not have permission.
  def show_user_not_authorized_error
    redirect_to request.referer || root_path,
                flash: { error: t(:not_authorized, scope: 'authorization') }
  end

  # Rescue raise ActiveRecord::DeleteRestrictionError, which happens when trying
  # do delete records restricted by "dependent: :restrict_with_exception"
  def show_delete_restriction_error(exception)
    redirect_to request.referer || root_path,
                flash: { error: exception.message }
  end
end
