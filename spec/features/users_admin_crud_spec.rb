require 'rails_helper'

describe 'User management for admins', type: :feature, js: true do
  def action_icon_selector(title_i18n_key, href)
    "[data-original-title='#{I18n.t(title_i18n_key)}'][href='#{href}']"
  end

  def sort_order_regex(sort_by_attribute)
    # Check the record's order by matching the order of their e-mails (unique)
    # #sort_by is slower than #order but it works with the full_name virtual
    # attribute.
    /#{User.all
           .sort_by(&sort_by_attribute)
           .map { |u| Regexp.quote(u.email) }
           .join(".+")}/
  end

  let(:user) { FactoryBot.create(:admin_user) }
  let(:valid_attributes) { FactoryBot.attributes_for(:user) }

  before(:each) { login_as(user) }

  describe 'create a new user' do
    describe 'GET #edit' do
      it 'requires login' do
        logout(:user)
        visit new_admin_user_path
        expect(page).to require_login_web
      end

      it 'enforces authorization' do
        # Expecting Pundit's #authorize to be called is enough to ensure
        # authorization is enforced. This is a very fast test.
        mock_pundit_authorize
        visit new_admin_user_path
      end
    end

    describe 'POST #create' do
      it 'requires login' do
        visit new_admin_user_path
        # Logging out programatically does not change the current page.
        logout(:user)
        click_button 'Create user'
        expect(page).to require_login_web
      end

      it 'enforces authorization' do
        visit new_admin_user_path
        mock_pundit_authorize
        click_button 'Create user'
        # An internal server error happens here, possibly due to a limitation of
        # #expect_any_instance_of. Regardless, this test ensures that
        # authorization is enforced (Pundit's #authorize is called).
      end
    end

    it 'given valid input, creates a new user' do
      visit new_admin_user_path
      expect do
        # Implemented in spec/support/helpers/capybara_fill_user_fields.rb
        fill_user_fields(valid_attributes)
        click_button 'Create user'
        # Keep this inside the expect block to ensure it waits until the new
        # record is created before recounting records.
        expect(page).to have_current_path(admin_user_path(User.last))
      end.to change(User, :count).by(1)
      expect(page).to have_text 'successfully created.'
      expect(page).to have_text "Name #{valid_attributes[:first_name]}"
    end

    it 'given invalid input, re-renders the form' do
      visit new_admin_user_path
      click_button 'Create user'
      expect(page).to have_text 'Please fix the following'
    end
  end

  describe 'displays an existing user' do
    it 'requires login' do
      logout(:user)
      visit admin_user_path(user)
      expect(page).to require_login_web
    end

    it 'enforces authorization' do
      # Expecting Pundit's #authorize to be called is enough to ensure
      # authorization is enforced. This is a very fast test.
      mock_pundit_authorize
      visit admin_user_path(user)
    end

    it 'shows the user' do
      visit admin_user_path(user)
      [
        "E-mail #{user.email}",
        "Role #{user.role}",
        "Full Name #{user.full_name}"
      ].each do |text|
        expect(page).to have_text text
      end
    end
  end

  describe 'edit an existing user' do
    describe 'GET #edit' do
      it 'requires login' do
        logout(:user)
        visit edit_admin_user_path(user)
        expect(page).to require_login_web
      end

      it 'enforces authorization' do
        # Expecting Pundit's #authorize to be called is enough to ensure
        # authorization is enforced. This is a very fast test.
        mock_pundit_authorize
        visit edit_admin_user_path(user)
      end
    end

    describe 'PATCH #update' do
      it 'requires login' do
        visit edit_admin_user_path(user)
        logout(:user)
        click_button 'Update user'
        expect(page).to require_login_web
      end

      it 'enforces authorization' do
        visit edit_admin_user_path(user)
        mock_pundit_authorize
        click_button 'Update user'
        # An internal server error happens here, possibly due to a limitation of
        # #expect_any_instance_of. Regardless, this test ensures that
        # authorization is enforced (Pundit's #authorize is called).
      end
    end

    it 'given valid input, edits an existing user' do
      visit edit_admin_user_path(user)
      # Test the app's ability to update a user without changing its password
      fill_user_fields(valid_attributes.except(:password,
                                               :password_confirmation))
      click_button 'Update user'
      expect(page).to have_current_path(admin_user_path(User.last))
      expect(page).to have_text 'successfully updated.'
      expect(page).to have_text "Name #{valid_attributes[:first_name]}"
    end

    it 'given invalid input, re-renders the form' do
      visit edit_admin_user_path(user)
      fill_in 'E-mail', with: ''
      click_button 'Update user'
      expect(page).to have_text 'Please fix the following'
    end
  end

  describe 'Lists all existing users' do
    let(:users) { FactoryBot.create_pair(:user) << user }

    it 'requires login' do
      logout(:user)
      visit admin_users_path
      expect(page).to require_login_web
    end

    it 'enforces authorization' do
      # Expecting Pundit's #policy_scope to be called is enough to ensure
      # authorization is enforced. This is a very fast test.
      expect_any_instance_of(ApplicationController).to \
        receive(:policy_scope).and_call_original
      visit admin_users_path
    end

    it 'displays all existing users' do
      # Create one more user
      users = [user, FactoryBot.create(:user)]

      visit admin_users_path
      expect(page).to have_selector('tr.user', count: users.count)

      users.each do |user|
        # <tr>s must have user_x (x is the record slug) as DOM ID
        within("#user_#{user.slug}") do
          expected_regex = /#{[
            user.email,
            user.role,
            user.full_name
          ].join(".*")}/
          expect(page).to have_text expected_regex
        end
      end
    end

    it "contains links to 'show', 'edit' and 'delete' each item" do
      visit admin_users_path
      expect(page).to have_selector(
        action_icon_selector('actions.show', admin_user_path(user))
      )
      expect(page).to have_selector(
        action_icon_selector('actions.edit', edit_admin_user_path(user))
      )
      expect(page).to have_selector(
        action_icon_selector('actions.delete', admin_user_path(user))
      )
    end

    # Do *not* replace it_behaves_like by include_examples
    it_behaves_like 'pagination', model: User, page_path: '/admin/users'

    describe 'sorting' do
      # Trigger the lazy creation of 2 additional records
      before(:each) { users }
      include_examples 'sort link',
                       model: User,
                       page_path: '/admin/users',
                       initial_sort_order: :full_name,
                       sort_links_and_attributes: {
                         'E-mail' => :email,
                         # "Role" => :role,
                         'Full Name' => :full_name
                       }
    end

    describe 'filtering' do
      it 'filters by email' do
        # Trigger the lazy creation of 2 additional records. E-mails are unique.
        users
        visit admin_users_path
        expect(page).to have_selector('tr.user', count: 3)
        fill_in 'q_email_cont', with: user.email
        click_on 'Apply'
        expect(page).to have_single_record(User, user.slug)
        # Test the filter's "Clear" button
        click_on 'Clear'
        expect(page).to have_selector('tr.user', count: 3)
      end

      it 'filters by full_name' do
        # The logged in user (created by let!(:user)) has a different name
        user = FactoryBot.create(:user,
                                  first_name: 'Unique',
                                  last_name: 'Name')
        visit admin_users_path
        expect(page).to have_selector('tr.user', count: 2)
        fill_in 'q_full_name_cont', with: 'Unique Name'
        click_on 'Apply'
        expect(page).to have_single_record(User, user.slug)
      end

      it 'filters by role' do
        # The logged in user (created by let(:user)) has :admin role
        user = FactoryBot.create(:user, role: :user)
        visit admin_users_path
        expect(page).to have_selector('tr.user', count: 2)
        select 'user', from: 'q_role_eq'
        click_on 'Apply'
        expect(page).to have_single_record(User, user.slug)
      end
    end
  end

  describe 'delete a user' do
    # Create a new user so the logged-in user does not get deleted
    let(:deletable_user) { FactoryBot.create(:user) }

    def click_delete
      find_by_i18n_title('actions.delete').click
      click_on 'Confirm'
    end

    it 'requires login' do
      visit admin_user_path(deletable_user)
      logout(:user)
      click_delete
      expect(page).to require_login_web
    end

    it 'enforces authorization' do
      visit admin_user_path(deletable_user)
      mock_pundit_authorize
      click_delete
      # An internal server error happens here, possibly due to a limitation of
      # #expect_any_instance_of. Regardless, this test ensures that
      # authorization is enforced (Pundit's #authorize is called).
    end

    it 'destroys the user' do
      visit admin_user_path(deletable_user)
      expect do
        click_delete
        # Redirect to the index view after record is destroyed.
        # Must be inside the #expect block to ensure the DB operation is
        # finished before trying to count records.
        expect(page).to have_current_path(admin_users_path)
      end.to change(User, :count).by(-1)
    end
  end
end
