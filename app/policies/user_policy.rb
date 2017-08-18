# Authorization policy for Admin::UsersController. *Not* used by Devise's
# controllers.
class UserPolicy < ApplicationPolicy
  # Used by Pundit's #policy_scope
  class Scope < Scope
    def resolve
      # Only admins can list users.
      user.admin? ? scope.all : scope.none
    end
  end

  # Only admins may use this controller
  %w[create? show? update? destroy?].each do |method_name|
    define_method(method_name) do
      user.present? && user.admin?
    end
  end
end
