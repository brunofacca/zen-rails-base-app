# frozen_string_literal: true

# :nocov:
class ApplicationMailer < ActionMailer::Base
  default from: 'replace@me.com'
  layout 'mailer'
end
# :nocov:
