# Simple helpers that are used across multiple specs.
module MiscTestHelpers
  def fill_user_fields(valid_attributes)
    attr = valid_attributes
    fill_in 'E-mail', with: attr[:email] if attr[:email]
    fill_in 'Password', with: attr[:password] if attr[:password]
    fill_in 'Password confirmation', with: attr[:password] if attr[:password]
    fill_in 'First name', with: attr[:first_name] if attr[:first_name]
    fill_in 'Last name', with: attr[:last_name] if attr[:last_name]
  end

  # Ensure a controller action calls Pundit's #authorize method to enforce
  # the authorization policies. Simulate authorization granted or denied
  # without touching the actual policies.
  def mock_pundit_authorize(authorized: false)
    # Avoid Pundit::AuthorizationNotPerformedError when using "after_action
    # :verify_authorized". Use "allow" and not "expect" as #verify_authorized is
    # only called when we do not raise Pundit::NotAuthorizedError.
    allow_any_instance_of(ApplicationController).to receive(:verify_authorized)

    # This does NOT work in tests that perform more than one request, because
    # each request has a different controller instance and
    # #expect_any_instance_of can't handle messages to more than one object. See
    # https://relishapp.com/rspec/rspec-mocks/docs/working-with-legacy-code/any-instance
    expectation = expect_any_instance_of(ApplicationController).to \
      receive(:authorize)
    # Simulate a "not authorized" scenario
    expectation.and_raise(Pundit::NotAuthorizedError) unless authorized
  end

  # This helper allows custom matchers and shared examples to guess factory
  # names based on model names. For this to work, factories must be named
  # accordingly to the naming convention suggested by the FactoryGirl docs.
  def factory_name(model)
    model.name.underscore.to_sym
  end

  # Find DOM element by title, given its I18n key. For use with Capybara.
  def find_by_i18n_title(i18n_key)
    # Bootstrap renames the "title" attribute to "data-original-title"
    find("[data-original-title='#{I18n.t(i18n_key)}']")
  end

  # Select an element on a select2 (https://select2.github.io/) dropdown.
  # May be called multiple times to select multiple items in a multiselect box.
  # For use with Capybara.
  def select_select2_option(option_text)
    first('.select2-container').click
    find('li', text: option_text).click
  end

  # Waits (halts test execution) until all jQuery AJAX requests are finished
  def wait_for_ajax(timeout_seconds)
    Timeout.timeout(timeout_seconds) do
      loop do
        active = page.evaluate_script('jQuery.active')
        break if active.zero?
      end
    end
  end
end
