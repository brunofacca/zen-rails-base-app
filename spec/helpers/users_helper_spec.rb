require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do
  describe '#password_placeholder' do
    it 'returns 8 bullet characters' do
      expect(helper.password_placeholder).to eq('&bull;' * 8)
    end
  end
end
