# Zen Rails Base Application

## Summary
Base or "skeleton" application for Ruby on Rails 5 projects. Built to 
minimize the time spent writing boilerplate code and performing repetitive 
setup tasks. 

Instead of using the Rails templating system to allow the user to choose which
templating engine, test framework, JS framework and other tools to use, it comes
with a preselected set of tools (which I use in most of my projects). If you are
looking for a more flexible application template, [Rails
Composer](http://www.railscomposer.com/) may be a better fit.

It consists of a Rails 5.1.3 app, including:
- `Gemfile` containing useful gems for development and debugging such as 
[awesome_print](), [byebug](), [better_errors]()
- Preconfigured test environment, including:
    - RSpec, FactoryGirl, Capybara configured to work with Selenium and 
    ChromeDriver, Database Cleaner, and SimpleCov.
    - General purpose test helpers, custom matchers and shared examples. See 
    `spec/support`. 
- Preconfigured authentication with the [Devise
gem](https://github.com/plataformatec/devise)
- Preconfigured authorization with the [Pundit gem](https://github
.com/elabs/pundit)
- Internationalization (i18n): All of the base application's strings are in 
YML dictionaries. This is arguably a good practice even for single language 
applications. Having an internationalized base application makes it easier
and faster to translate elements like Devise, the layout and error messages 
(e.g., when creating a single language app in a non-enlglish language).
- jQuery ([jquery-rails gem](https://github.com/rails/jquery-rails))
- HTML Layouts (to use as a starting point) developed with Bootstrap 3 
([bootstrap-sass gem](https://github.com/twbs/bootstrap-sass)), including:
    - Navigation bar;
    - Displaying of flash messages and validation errors as colored Bootstrap 
    alerts;
    - Role-based layout switching: different layouts for guests 
    (unauthenticated users), ordinary users and admins;
- Controller concerns such as `SkipAuthorization`.
- Display user-friendly error messages (flash) on exceptions such as 
`ActiveRecord::DeleteRestrictionError` and `Pundit::NotAuthorizedErrorand`. 
User-friendly error messages for exceptions
- User management interface for admins in `/admin/users` with pagination
([kaminari gem](https://github.com/kaminari/kaminari)) and searching ([ransack
gem](https://github.com/activerecord-hackery/ransack)). Accessible only by 
admin users.
with "admin" role. 
- Seed users for the development environment. Run `rails db:seed` to 
create them:
    - Ordinary user: email: `user@myapp.com` / password: `Devpass1`
    - Admin user: email: `admin@myapp.com` / password: `Devpass1`
- Contact form built with the [mail_form
gem](https://github.com/plataformatec/mail_form)
- E-mails "sent" in the development environment are saved in html files at
`tmp/letter_opener` ([letter_opener
gem](https://github.com/ryanb/letter_opener)).
- ZenUtils: a small JavaScript library consisting of utility functions. See 
`app/assets/javascripts/zen-utils.js`  
- SCSS utility classes for alignment, spacing and font size standardization. 
See `app/assets/stylesheets/utility-classes.scss`.
- Test test coverage of 97%, calculated by 
[SimpleCov](https://github.com/colszowka/simplecov).

## Usage
Setup tasks such as configuring  time zones, default locale and action mailer
(e.g., SMTP or transactional e-mail service) are not included in the following
steps as they are not specific to this base app.

1. Fork this repository.
2. Clone the forked repository to your machine.
3. Run `bundle install`
4. Rename the application: 
    1. *Required*: change the module name in `config/application.rb` 
from `ZenRailsBaseApp` to your application name, in camel case.
    2. *Optional*: Use your IDE's "search all files" feature to find and 
    replace all occurences of the following strings:
        - `zen_rails_base_app` by `your_app_name` 
        - `ZEN_RAILS_BASE_APP` by `YOUR_APP_NAME`
        - `Project Name` by the project's name
        - `replace@me.com` replace manually by the different e-mail addresses
        that should receive messages sent via contact form, notification
        exceptions, etc.
5. Configure the databases: If using PostgreSQL, uncomment the `pg` gem from 
the `Gemfile`, if using MySQL uncomment `mysql2`. Also uncomment the section of 
`config/database.yml` corresponding to your chosen DBMS.
    1. The `Gemfile` contains both `pg` and `mysql2` gem. Choose the DB
5. Customise the authentication setup. You may want to change one or more of 
the following defaults: 
    - Set an environment
    - Aside from Devise's default attributes,
    the `User` model of this app also has `role`, `first_name` and `last_name` 
    attributes. 
    - Aside from the Devise modules that are activated by default, this app 
    also uses the Confirmable, Timeoutable and Lockable modules. 
    - The app uses Pundit for authorization. The `User` model has an enum 
    called `role`, whith `user` and `admin` as its possible values and `user`
    as a default value. 
    - Devise configurations at `config/initializers/devise.rb`, 
    especially `config.mailer_sender`. 
5. Customize the application colors by overwriting the Bootstrap variables in 
`app/assets/stylesheets/global.scss`
6. Remove unused items from the application, such as gems from the `Gemfile` 
and RSpec helpers, custom matchers and shared examples from `spec/support`. 
7. Start coding!

The application is configured to use PostgreSQL. To use MySQL or another 
database, just edit `config/database.yml`.

## Contributing

**Bug reports**

Please use the issue tracker to report any bugs.

**Developing**

1. Create an issue and describe your idea
2. Fork it
3. Create your feature branch (git checkout -b my-new-feature)
4. Commit your changes (git commit -m 'Add some feature')
5. Publish the branch (git push origin my-new-feature)
6. Create a Pull Request

## License

Released under the [MIT License](https://opensource.org/licenses/MIT).







This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
