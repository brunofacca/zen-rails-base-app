require 'rails_helper'

RSpec.describe ContactForm, type: :model do
  let(:valid_attributes) { FactoryBot.attributes_for(:contact_form) }

  # Custom matchers such as be_invalid_without_a and have_a_valid_factory do not
  # work as ContactForm is not a real model (it is a subclass of
  # MailForm::Base). It also does not respond to #create and #save, only #new
  it 'has a valid factory' do
    contact_form = ContactForm.new(valid_attributes)
    expect(contact_form).to be_valid
  end

  %i[name email message].each do |attribute|
    it "is invalid without a #{attribute}" do
      invalid_attributes = valid_attributes.merge(attribute => nil)
      contact_form = ContactForm.new(invalid_attributes)
      expect(contact_form).not_to be_valid
    end
  end

  it 'prevents SPAM by not delivering messages when the honeypot field is filled' do
    contact_form = ContactForm.new(valid_attributes.merge(robot_honeypot: 'Foo'))
    # #spam? returns raises an exception in the development environment, but not
    # in the test environment. This is by design.
    expect(contact_form).to be_spam
  end
end
