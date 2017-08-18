# This module should be included in controllers that do not require
# authorization. To use it, add the following line to the controller:
# include SkipAuthorization
module SkipAuthorization
  extend ActiveSupport::Concern

  included do
    skip_after_action :verify_authorized, raise: false
    skip_after_action :verify_policy_scoped, raise: false
  end
end
