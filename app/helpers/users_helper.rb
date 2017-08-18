# :nodoc:
module UsersHelper
  def password_placeholder
    ('&bull;' * 8).html_safe
  end
end
