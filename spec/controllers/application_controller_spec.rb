require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  before(:each) { login_user }

  controller do
    # Avoid Pundit::AuthorizationNotPerformedError as our anonymous
    # controller does not call #authorize
    skip_after_action :verify_authorized
    skip_before_action :authenticate_user!

    # RSpec's anonymous controllers only create routes for the standard
    # RESTful actions (index, new, create, show, edit, update, destroy)
    def show
      raise Pundit::NotAuthorizedError
    end

    def destroy
      raise ActiveRecord::DeleteRestrictionError, 'foo'
    end
  end

  describe 'when a Pundit::NotAuthorizedError is raised' do
    before(:each) { get :show, params: { id: 1 } }

    it 'redirects back to root path (there is no referrer URL in the test)' do
      expect(response).to redirect_to(root_path)
    end

    it 'generates a flash message' do
      expect(flash[:error]).to include('not authorized')
    end
  end

  describe 'when a ActiveRecord::DeleteRestrictionError is raised' do
    before(:each) { delete :destroy, params: { id: 1 } }

    it 'redirects back to root path (there is no referrer URL in the test)' do
      expect(response).to redirect_to(root_path)
    end

    it 'generates a flash message' do
      expect(flash[:error]).to include('Cannot delete record')
    end
  end
end
