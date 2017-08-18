require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#bootstrap_class_for' do
    {
      success: 'alert-success',
      error: 'alert-danger',
      alert: 'alert-warning',
      notice: 'alert-info'
    }.each do |flash_type, bootstrap_class|
      it "uses the #{bootstrap_class} Bootstrap class for #{flash_type} flash messages" do
        expect(helper.bootstrap_class_for(flash_type.to_s)).to \
          eq(bootstrap_class)
      end
    end
  end

  describe '#display_validation_errors' do
    let(:object) do
      object = double('active-record-object')
      allow(object).to receive_message_chain('errors.empty?') { false }
      allow(object).to receive_message_chain('errors.count') { 2 }
      allow(object).to receive_message_chain('errors.full_messages') do
        ['Fake error 1', 'Fake error 2']
      end
      object
    end

    it 'returns the correct header message' do
      expect(helper.display_validation_errors(object)).to include(
        I18n.t('activerecord.errors.template.header', count: 2)
      )
    end

    it "returns the object's errors" do
      expect(helper.display_validation_errors(object)).to \
        include('Fake error 1', 'Fake error 2')
    end
  end
end
