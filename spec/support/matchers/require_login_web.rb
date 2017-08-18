RSpec::Matchers.define :require_login_web do
  match do |page|
    # Expect a redirection to the login page
    expect(page).to have_current_path new_user_session_path
    expect(page).to have_text I18n.t('devise.failure.unauthenticated')
  end

  failure_message do
    'expected this page to require login'
  end

  failure_message_when_negated do
    'expected this page NOT to require login'
  end
end
