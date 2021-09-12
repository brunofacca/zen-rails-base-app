require 'rails_helper'

describe 'Contact form via UI', type: :feature, js: true do
  let(:valid_attributes) { FactoryBot.attributes_for(:contact_form) }

  it 'given valid input, it delivers a message' do
    visit '/contact'
    fill_in 'Name', with: valid_attributes[:name]
    fill_in 'Email', with: valid_attributes[:email]
    fill_in 'Message', with: valid_attributes[:message]
    click_on 'Send message'

    # Open last sent e-mail and set current_email variable
    # Implemented by https://github.com/DockYard/capybara-email
    open_email('replace@me.com')
    expect(current_email).to have_text "Name: #{valid_attributes[:name]}"
    expect(current_email).to have_text "Email: #{valid_attributes[:email]}"
    expect(current_email).to have_text "Message: #{valid_attributes[:message]}"

    expect(page).to have_text I18n.t('contact_forms.create.success')
  end

  it 'given invalid input, re-renders the form' do
    visit '/contact'
    click_on 'Send message'
    expect(page).to have_text 'Please fix the following'
  end
end
