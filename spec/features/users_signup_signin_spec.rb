require 'rails_helper'

def login_via_form(email, password)
  expect(page).to have_current_path(new_user_session_path)
  fill_in 'E-mail', with: email
  fill_in 'Password', with: password
  click_button 'Sign in'
end

def click_navbar_dropdown_item(link_text)
  # Open Bootstrap dropdown at navbar
  find('li.dropdown', text: user.full_name).click
  click_on link_text
end

RSpec::Matchers.define :be_logged_in do |user_full_name|
  match do |page|
    expect(page).to have_selector('li.dropdown', text: user_full_name)
  end
  failure_message do
    "expected to find a the user's full name (#{user_full_name}) in the " \
    "navbar. Found '#{find(".navbar-default").text}' instead."
  end
end

# Most of the items tested here are standard Devise features. However, we
# have customized all of Devise's views, some controllers and the way
# validation errors are displayed. Hence, it is important to test everything.
describe 'User self-management via UI', type: :feature, js: true do
  let!(:user) { FactoryBot.create(:user) }
  let(:valid_attributes) { FactoryBot.attributes_for(:user) }

  it 'registers a new user and logs in via form' do
    visit '/'

    within 'nav' do
      click_link 'Sign up'
    end

    fill_user_fields(valid_attributes)
    within 'form#new_user' do
      click_button 'Sign up'
    end

    # The user may only login *after* confirming her e-mail
    expect(page).to have_text I18n.t(
      'devise.registrations.signed_up_but_unconfirmed'
    )
    expect(page).to have_current_path new_user_session_path

    # Find email sent to the given recipient and set current_email variable
    # Implemented by https://github.com/DockYard/capybara-email
    open_email(valid_attributes[:email])
    expect(current_email.subject).to eq I18n.t(
      'devise.mailer.confirmation_instructions.subject'
    )
    current_email.click_link I18n.t(
      'devise.mailer.confirmation_instructions.action'
    )

    expect(page).to have_text I18n.t('devise.confirmations.confirmed')

    login_via_form(valid_attributes[:email],
                   valid_attributes[:password])
    expect(page).to have_text I18n.t('devise.sessions.signed_in')
    expect(page).to be_logged_in(valid_attributes[:first_name])
  end

  it 'signs out' do
    login_as(user)
    visit '/'
    click_navbar_dropdown_item('Sign out')
    expect(page).to have_current_path(new_user_session_path)
  end

  it 'allows the user to edit his profile' do
    login_as(user)
    visit '/'

    click_navbar_dropdown_item('Edit profile')
    expect(page).to have_current_path(edit_user_registration_path)

    # Do not change email or else Devise will require reconfirmation
    fill_user_fields(valid_attributes.except(:email))
    fill_in 'Current password', with: user.password
    click_button 'Update'

    expect(page).to have_text I18n.t('devise.registrations.updated')
  end

  it 'performs password recovery (creates a new password)' do
    visit new_user_session_path
    click_link 'Forgot your password?'
    fill_in 'E-mail', with: user.email
    click_button 'Send me reset password instructions'

    expect(page).to have_text I18n.t('devise.passwords.send_instructions')

    # Find email sent to the given recipient and set current_email variable
    open_email(user.email)
    expect(current_email.subject).to eq 'Reset password instructions'
    current_email.click_link 'Change my password'

    fill_in 'New password', with: valid_attributes[:password]
    fill_in 'Confirm new password', with: valid_attributes[:password]
    click_button 'Change my password'

    expect(page).to have_text I18n.t('devise.passwords.updated')
    expect(page).to be_logged_in(user.first_name)

    open_email(user.email)
    expect(current_email.subject).to eq I18n.t(
      'devise.mailer.reset_password_instructions.subject'
    )
    expect(current_email.body).to have_text I18n.t(
      'devise.mailer.reset_password_instructions.instruction'
    )
  end

  describe 'resend confirmation e-mail' do
    context 'with an already confirmed e-mail address' do
      it 'warns the user and does not send a new confirmation e-mail' do
        # Our factory creates users with confirmed e-mails
        visit new_user_session_path
        click_link "Didn't receive confirmation instructions?"
        fill_in 'E-mail', with: user.email
        expect do
          click_button 'Resend confirmation instructions'
          # Expectation must be inside expect block to force Capybara to wait
          expect(page).to have_text I18n.t(
            'errors.messages.already_confirmed'
          )
        end.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end

    context 'with an unconfirmed e-mail address' do
      it 'sends a new confirmation e-mail' do
        # Unconfirm user (our factory creates users with confirmed e-mails)
        user.update(confirmed_at: nil)

        visit new_user_session_path
        click_link "Didn't receive confirmation instructions?"
        fill_in 'E-mail', with: user.email
        click_button 'Resend confirmation instructions'

        expect(page).to have_text I18n.t(
          'devise.confirmations.send_instructions'
        )

        open_email(user.email)
        expect(current_email.subject).to eq 'Confirmation instructions'
        current_email.click_link 'Confirm my account'

        expect(page).to have_text I18n.t(
          'devise.confirmations.confirmed'
        )

        login_via_form(user.email, user.password)
        expect(page).to have_text I18n.t('devise.sessions.signed_in')
        expect(page).to be_logged_in(user.first_name)
      end
    end
  end

  it 'locks the account after 5 failed login attempts' do
    visit new_user_session_path

    3.times do
      login_via_form(user.email, 'bogus')
      expect(page).to have_text I18n.t('devise.failure.invalid')
    end

    login_via_form(user.email, 'bogus')
    expect(page).to have_text I18n.t('devise.failure.last_attempt')

    login_via_form(user.email, 'bogus')
    expect(page).to have_text I18n.t('devise.failure.locked')

    open_email(user.email)
    expect(current_email.subject).to eq 'Unlock instructions'
    current_email.click_link 'Unlock my account'

    expect(page).to have_text I18n.t('devise.unlocks.unlocked')

    login_via_form(user.email, user.password)
    expect(page).to have_text I18n.t('devise.sessions.signed_in')
    expect(page).to be_logged_in(user.first_name)
  end

  context "account is locked, didn't receive unlocking instructions" do
    it 'sends a new unlocking instructions e-mail' do
      user.update(locked_at: DateTime.current)

      visit new_user_session_path
      click_link "Didn't receive unlock instructions?"
      fill_in 'E-mail', with: user.email
      click_button 'Resend unlock instructions'

      expect(page).to have_text I18n.t('devise.unlocks.send_instructions')

      open_email(user.email)
      expect(current_email.subject).to eq 'Unlock instructions'
      current_email.click_link 'Unlock my account'

      expect(page).to have_text I18n.t('devise.unlocks.unlocked')

      login_via_form(user.email, user.password)
      expect(page).to have_text I18n.t('devise.sessions.signed_in')
      expect(page).to be_logged_in(user.first_name)
    end
  end

  context 'account is not locked, attempts to re-send unlocking instructions' do
    it 'warns the user and does not send a new confirmation e-mail' do
      # Our factory creates users with confirmed e-mails
      visit new_user_session_path
      click_link "Didn't receive unlock instructions?"
      fill_in 'E-mail', with: user.email
      expect do
        click_button 'Resend unlock instructions'
        # Expectation must be inside expect block to force Capybara to wait
        expect(page).to have_text I18n.t('errors.messages.not_locked')
      end.not_to change(ActionMailer::Base.deliveries, :count)
    end
  end
end
