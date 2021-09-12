# USAGE
#
# Parameters:
#   - controller_class: class of this resource's controller
#   - resource_path: path (URL without domain) of this resource in the API
#   - *comparable_attributes: Array containing some of the of attributes
#     that are present in both the model and the API representation of the
#     resource. Used to compare the values of API JSON responses to specific
#     to the test data (records or valid_attributes hashes).
# Example:
#
# it_behaves_like "a RESTful JSON API",
#                 controller_class: Api::V1::UsersController,
#                 resource_path: "/api/v1/users",
#                 *comparable_attributes: [:id, :email, :first_name, :last_name]

RSpec.shared_examples 'a RESTful JSON API',
  http_error_instead_of_exception: true do |controller_class:,
                                            resource_path:,
                                            comparable_attributes:,
                                            is_singular_resource: false|

  def self.controller_has_action?(controller_class, action)
    controller_class.action_methods.include?(action.to_s)
  end

  def expected_attribute_values(all_attributes, comparable_attributes)
    all_attributes.with_indifferent_access
                  .slice(*comparable_attributes)
                  .deep_transform_keys! { |key| key.camelize(:lower) }
  end

  resource_singular = resource_path.split('/').last.singularize.to_sym
  resource_plural = resource_path.split('/').last.pluralize.to_sym

  before(:each) do
    login_admin
  end

  let(:record) { FactoryBot.create(resource_singular) }
  let(:records) { FactoryBot.create_pair(resource_singular) }
  # Models that validate the presence of associated records require some
  # hacking in the factory to include associations in #attributes_for
  let(:valid_attributes) { FactoryBot.attributes_for(resource_singular) }
  # All factories must have a trait called :invalid
  let(:invalid_attributes) do
    FactoryBot.attributes_for(resource_singular, :invalid)
  end
  let(:response_json) { JSON.parse(response.body) }
  let(:request_path) do
    # Singular resource does not include record ID in path
    resource_path + (is_singular_resource ? '' : "/#{record.id}")
  end

  describe 'GET #index', if:
    controller_has_action?(controller_class, :index) do

    before(:each) do
      # Test data is lazily created. Here we must force it to be created.
      records
    end

    it 'requires authentication' do
      logout_example
      get resource_path
      expect(response).to require_login_api
    end

    it 'enforces authorization' do
      expect_any_instance_of(Api::V1::BaseApiController).to \
        receive(:policy_scope).and_call_original
      get resource_path
    end

    it "returns a 'OK' (200) HTTP status code" do
      get resource_path
      expect(response).to have_http_status(200)
    end

    it "returns all #{resource_plural}" do
      get resource_path
      # When testing the User model, a user created by the Devise login helper
      # increases the expected record count to 3.
      expected_count = resource_singular == :user ? 3 : 2
      expect(response_json.size).to eq(expected_count)
    end
  end

  describe 'GET #show', if:
    controller_has_action?(controller_class, :show) do

    it 'requires authentication' do
      logout_example
      get request_path
      expect(response).to require_login_api
    end

    it 'enforces authorization' do
      mock_pundit_authorize(authorized: false)
      get request_path
      expect(response).to enforce_authorization_api
    end

    context "with a valid #{resource_singular} ID" do
      before(:each) do
        get request_path
      end

      it "returns a 'OK' (200) HTTP status code" do
        expect(response).to have_http_status(200)
      end

      it "returns the requested #{resource_singular}" do
        # "user" is a singular resource in our API. It always points to the
        # currently logged in user. @current_user is set in
        # spec/support/helpers/devise_request_spec_login.rb. All other resources
        # are plural and point to the record whose ID we provide in the request
        # path.
        expected_record = resource_singular == :user ? @current_user : record

        expect(response_json).to include(
          expected_attribute_values(expected_record.attributes,
                                    comparable_attributes)
        )
      end
    end

    context "with an invalid #{resource_singular} ID" do
      before(:each) { get "#{resource_path}/9999" }

      it "returns a 'not found' (404) status code" do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST #create', if:
    controller_has_action?(controller_class, :create) do

    before(:each) do
      # A user cannot be logged-in before signing-up
      logout_example if resource_singular == :user
    end

    if resource_singular == :user
      # A user cannot be logged-in before signing-up
      it 'does not require authentication' do
        logout_example
        post resource_path, resource_singular => valid_attributes
        expect(response).not_to require_login_api
      end
    else
      it 'requires authentication' do
        logout_example
        post resource_path, resource_singular => valid_attributes
        expect(response).to require_login_api
      end
    end

    it 'enforces authorization' do
      mock_pundit_authorize(authorized: false)
      post resource_path, resource_singular => valid_attributes
      expect(response).to enforce_authorization_api
    end

    context 'with valid attributes' do
      before(:each) do
        post resource_path, resource_singular => valid_attributes
      end

      it "returns a 'created' (201) HTTP status code" do
        expect(response).to have_http_status(201)
      end

      it "returns the created #{resource_singular}" do
        expect(response_json).to include(
          expected_attribute_values(valid_attributes, comparable_attributes)
        )
      end
    end

    context 'with invalid attributes' do
      before(:each) do
        post resource_path, resource_singular => invalid_attributes
      end

      it "returns a 'unprocessable entity' (422) HTTP status code" do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PATCH #update', if:
    controller_has_action?(controller_class, :update) do

    it 'requires authentication' do
      logout_example
      patch request_path, resource_singular => valid_attributes
      expect(response).to require_login_api
    end

    it 'enforces authorization' do
      mock_pundit_authorize(authorized: false)
      patch request_path, resource_singular => valid_attributes
      expect(response).to enforce_authorization_api
    end

    context 'with valid attributes' do
      before(:each) do
        patch request_path, resource_singular => valid_attributes
      end

      it "returns a 'OK' (200) HTTP status code" do
        expect(response).to have_http_status(200)
      end

      it "returns the updated #{resource_singular}" do
        record.reload
        expect(response_json).to include(
          expected_attribute_values(valid_attributes, comparable_attributes)
        )
      end
    end

    context 'with invalid attributes' do
      before(:each) do
        patch request_path, resource_singular => invalid_attributes
      end

      it "returns an 'unprocessable entity' (422) status code" do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE #destroy', if:
    controller_has_action?(controller_class, :destroy) do

    it 'requires authentication' do
      logout_example
      delete request_path
      expect(response).to require_login_api
    end

    it 'enforces authorization' do
      mock_pundit_authorize(authorized: false)
      delete request_path
      expect(response).to enforce_authorization_api
    end

    # Skip this test for the "user" resource. It is a singular resource which
    # points to the currently logged in user. If we delete it, we're
    # automatically logged out and the second request (get) returns 302. If a
    # new user is created before the get request, it returns 200. Hence, it
    # can never return 404.
    unless resource_singular == :user
      it "deletes the #{resource_singular}" do
        delete request_path
        get request_path
        expect(response).to have_http_status(404)
      end
    end

    it "returns a 'no content' (204) status code" do
      delete request_path
      expect(response).to have_http_status(204)
    end
  end
end
