require 'rails_helper'

describe ApplicationPolicy do
  describe 'policies' do
    subject { ApplicationPolicy.new(nil, nil) }

    %i[new create show edit update destroy].each do |method|
      it { is_expected.not_to permit(method) }
    end
  end
end
