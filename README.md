# Zen Rails Base Application

## Summary
Base or "skeleton" application for Ruby on Rails 5.1 projects. Built to 
minimize the time spent writing boilerplate code and performing repetitive 
setup tasks. 

Instead of using the Rails templating system to allow the user to choose which
templating engine, test framework, JS framework and other tools to use, it comes
with a preselected set of tools (which I use in most of my projects). If you are
looking for a more flexible application template, [Rails
Composer](http://www.railscomposer.com/) may be a better fit.

## Features
It consists of a Rails 5.1.3 app, including:
- A selection of useful gems for development and debugging such as
[rubocop](https://github.com/bbatsov/rubocop),
[brakeman](https://github.com/presidentbeef/brakeman),
[awesome_print](https://github.com/awesome-print/awesome_print),
[byebug](https://github.com/deivid-rodriguez/byebug), and
[better_errors](https://github.com/charliesome/better_errors).
- Preconfigured test environment, including:
    - [RSpec](http://rspec.info),
    [FactoryGirl](https://github.com/thoughtbot/factory_girl),
    [Capybara](https://github.com/teamcapybara/capybara) configured to work with
    [Selenium](http://www.seleniumhq.org/projects/webdriver/) and
    [ChromeDriver](https://sites.google.com/a/chromium.org/chromedriver/),
    [Database Cleaner](https://github.com/DatabaseCleaner/database_cleaner),
    and [SimpleCov](https://github.com/colszowka/simplecov).
    - General purpose test helpers, custom matchers and shared examples. See 
    `spec/support`. 
- Preconfigured authentication with the [Devise
gem](https://github.com/plataformatec/devise)
- Preconfigured authorization with the [Pundit
gem](https://github.com/elabs/pundit)
- Internationalization (i18n): All of the base application's strings are in 
YML dictionaries. This is arguably a good practice even for single language 
applications. Having an internationalized base application makes it easier
and faster to translate elements like Devise, the layout and error messages 
(e.g., when creating a single language app in a non-English language).
- jQuery
- HTML Layouts (to use as a starting point) developed with Bootstrap 3 
([bootstrap-sass gem](https://github.com/twbs/bootstrap-sass)), including:
    - Navigation bar;
    - Displaying of flash messages and validation errors as Bootstrap alerts;
    - Role-based layout switching: different layouts for guests 
    (unauthenticated users), ordinary users and admins;
- Controller concerns such as `SkipAuthorization`.
- User-friendly error messages (flash) on exceptions such as 
`ActiveRecord::DeleteRestrictionError` and `Pundit::NotAuthorizedErrorand`.
- User management interface for admins in `/admin/users` with pagination
([kaminari gem](https://github.com/kaminari/kaminari)) and searching/filtering 
([ransack
gem](https://github.com/activerecord-hackery/ransack)). Accessible only by 
users with "admin" role. 
- Seed users for the development environment. Run `rails db:seed` to 
create them:
    - Ordinary user: email: `user@test.com` / password: `Devpass1`
    - Admin user: email: `admin@test.com` / password: `Devpass1`
- Contact form built with the [mail_form
gem](https://github.com/plataformatec/mail_form).
- E-mails "sent" in the development environment are saved in html files at
`tmp/letter_opener` ([letter_opener
gem](https://github.com/ryanb/letter_opener)).
- The following JavaScript libraries:
  - [Select2](https://github.com/select2/select2) for better select boxes.
  - [SweetAlert2](https://github.com/limonte/sweetalert2) for better JS 
  popups. The default `data-confirm` confirmation is replaced by a 
  better-looking version.
  - ZenUtils: a small JavaScript library consisting of utility functions. See 
`app/assets/javascripts/zen-utils.js`  
- SCSS utility classes for alignment, spacing and font size standardization. 
See `app/assets/stylesheets/utility-classes.scss`.
- Test coverage of 97%.

## Development Environment Dependencies
- Ruby 2.3+
- [Yarn](https://yarnpkg.com/en/docs/install)
- Required for running JavaScript-enabled feature specs:
    - [Selenium](http://www.seleniumhq.org/projects/webdriver/)
    - [ChromeDriver](https://sites.google.com/a/chromium.org/chromedriver/)
    - [Xvfb](https://www.x.org/archive/X11R7.6/doc/man/man1/Xvfb.1.xhtml) if running feature specs on a console-only (no graphical 
    interface) *nix environment.

Consider using my [Zen Rails Development
Environment](https://github.com/brunofacca/rails-development-environment). It
 consists of a Ubuntu 16.04 (Xenial Xerus) Vagrant VM with all of the 
 above dependencies preinstalled.

## Usage
Setup tasks such as configuring  time zones, default locale and action mailer
(e.g., SMTP or transactional e-mail service) are not included in the following
steps as they are not specific to this base app.

1. Fork this repository.
2. Clone the forked repository to your machine.
3. Rename the application: 
    1. *Required*: change the module name in `config/application.rb` 
from `ZenRailsBaseApp` to your application name, in camel case.
    2. *Optional*: Use your IDE's "search all files" feature to find and 
    replace the following strings:
        - Replace `zen_rails_base_app` by `your_app_name` 
        - Replace `ZEN_RAILS_BASE_APP` by `YOUR_APP_NAME`
        - Replace `Project Name` by the project's name
        - Replace `replace@me.com`  manually by the different e-mail addresses
        that should send and receive e-mails in various parts of the 
        application.
4. Run `bundle install`
5. Configure the databases:
 
    1. If using PostgreSQL, uncomment the `pg` gem from the `Gemfile`, if 
    using MySQL uncomment the `mysql2` gem.

    2. Uncomment the section of `config/database.yml` corresponding to your 
    chosen DBMS.
  
5. Customise the authentication setup. You may want to change one or more of 
the following items: 
    - Aside from Devise's default attributes,
    the `User` model of this app also has `role`, `first_name`, and `last_name` 
    attributes. 
    - Aside from the Devise modules that are activated by default, this app 
    also uses the Confirmable, Timeoutable and Lockable modules. 
    - The app uses Pundit for authorization. The `User` model has an enum
    attribute called `role`, with `user` and `admin` as its possible values and
    `user` as a default value. 
    - Devise configurations at `config/initializers/devise.rb`, 
    especially `config.mailer_sender`. 
5. Customize the application colors by overwriting Bootstrap's variables in 
`app/assets/stylesheets/global.scss`
6. Remove unused items from the application, such as gems from the `Gemfile`, 
RSpec helpers, custom matchers and shared examples from `spec/support`. 


## TODO
- Set up CodeClimate with Rubocop, Reek and Brakeman engines.
- Use Yarn instead of gems to install front end libraries such as jQuery and 
Select2.
- Add an asterisk to the labels of required form fields.
- Internationalize and translate the JS front end, mainly `global.js` and 
`zen-utils.js`.

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
