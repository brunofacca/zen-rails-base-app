require 'rails_helper'

describe 'layout and UI elements', type: :feature, js: true do
  let(:admin_user) { FactoryBot.create(:admin_user) }
  let(:ordinary_user) { FactoryBot.create(:user) }

  context 'given an unauthenticated user' do
    it 'displays the appropriate layout and UI elements' do
      visit '/'
      within '.navbar-default' do
        expect(page).to have_link(I18n.t('navigation.home'),  href: root_path)
        expect(page).to have_link(I18n.t('navigation.contact'), href: contact_path)
        expect(page).to have_link(I18n.t('navigation.sign-up'), href: new_user_registration_path)
        expect(page).to have_link(I18n.t('navigation.sign-in'), href: new_user_session_path)
      end
    end
  end

  context 'given a user with :user role' do
    it 'displays the appropriate layout and UI elements' do
      login_as(ordinary_user)
      visit '/'
      expect(page).to have_link(I18n.t('navigation.home'), href: root_path)
      expect(page).to have_link(I18n.t('navigation.contact'), href: contact_path)
      expect(page).not_to have_link(I18n.t('navigation.users'), href: admin_users_path)
    end
  end

  context 'given a user with :admin role' do
    it 'displays the appropriate layout and UI elements' do
      login_as(admin_user)
      visit '/'
      expect(page).to have_link(I18n.t('navigation.home'), href: root_path)
      expect(page).to have_link(I18n.t('navigation.contact'), href: contact_path)
      expect(page).to have_link(I18n.t('navigation.users'), href: admin_users_path)
    end
  end
end
