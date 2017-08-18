# :nodoc:
class ContactForm < MailForm::Base
  attribute :name, validate: true
  attribute :email, validate: /.+@.+\..+/i
  attribute :message, validate: true
  # This corresponds to a hidden field that should not be filled by humans
  attribute :robot_honeypot, captcha: true

  # Include the client IP and user agent in the e-mail sent by mail_form
  append :remote_ip, :user_agent

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      subject: 'Project Name - Message sent via contact form',
      to: 'replace@me.com',
      from: %("#{name}" <#{email}>)
    }
  end
end
