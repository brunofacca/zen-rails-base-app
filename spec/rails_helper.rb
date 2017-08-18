# SimpleCov must be loaded and launched at the very top of this file
require 'simplecov'
SimpleCov.start 'rails'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if
  Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'capybara/rails'
require 'selenium/webdriver'
require 'capybara-screenshot/rspec'
require 'capybara/email/rspec'
require 'devise'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

# ---------------------- Begin Capybara configurations ----------------------
Capybara.register_driver :selenium do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  # The window size is important for screenshots
  options.add_argument '--window-size=1366,768'
  Selenium::WebDriver::Chrome.driver_path = '/usr/local/bin/chromedriver'
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :selenium

# Avoids problems related to config.action_mailer.default_url_options  when
# trying to follow links in e-mails
Capybara.always_include_port = true

# The default wait time of 2 seconds sometimes generates false
# positives (tests fail only because it took more than 2 secs for the page to
# load).
Capybara.default_max_wait_time = 5

# capybara-screenshot gem screebshot save path
Capybara.save_path = "#{::Rails.root}/tmp/capybara_screenshots"

# Allows finding and interacting with hidden elements. Useful when working
# with default browser elements that are hidden by Bootstrap (e.g., file
# input fields).
Capybara.ignore_hidden_elements = false
# ---------------------- End Capybara configurations ----------------------

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # Display all JavaScript errors (from the headless browser console) when
  # running JS-enabled feature specs with Selenium and Chrome. Should also
  # work with Firefox.
  class JavaScriptError < StandardError; end
  RSpec.configure do |config|
    config.after(:each, type: :feature, js: true) do
      errors = page.driver
                   .browser
                   .manage
                   .logs
                   .get(:browser)
                   .select { |e| e.level == 'SEVERE' && e.message.present? }
                   .map(&:message)
                   .to_a
      raise JavaScriptError, errors.join("\n\n") if errors.present?
    end
  end

  # Add ability to login/out programatically in controller specs (Devise)
  config.include Devise::Test::ControllerHelpers, type: :controller
  # Load the helpers in spec/support/helpers/devise_controller_spec_login.rb
  config.include DeviseControllerSpecLogin, type: :controller

  # Add ability to login/out programatically in request specs (Devise)
  # Load the helpers in spec/support/helpers/devise_request_spec_login.rb
  config.include DeviseRequestSpecLogin, type: :request

  # Add ability to login/out programatically in feature specs (Devise)
  # Implements the login_as(user) and logout(user) methods
  config.include Warden::Test::Helpers, type: :feature

  # Allows returning HTTP error status codes instead of raising exceptions
  # Usage: Add the http_error_instead_of_exception: true metadata
  # to the examples or example groups that should return HTTP error codes;
  config.include HttpErrorResponses
  config.around(http_error_instead_of_exception: true) do |example|
    respond_with_http_error_instead_of_exception(&example)
  end

  # Simple (small) helpers that are used across multiple specs.
  config.include MiscTestHelpers

  # ------------------- Begin Database Cleaner config --------------------
  config.use_transactional_fixtures = false

  config.before(:suite) do
    # Perform the initial DB cleaning by truncating all the tables
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    # Use the default transaction strategy (faster) in specs without JS
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    # Use truncation strategy in feature specs (Capybara) that use JS drivers
    # such as Selenium or Poltergeist
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  # Using #append_after instead of #after is very important to avoid race
  # conditions between tests.
  config.append_after(:each) do
    DatabaseCleaner.clean
  end
  # ------------------- End Database Cleaner config ---------------------

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end
