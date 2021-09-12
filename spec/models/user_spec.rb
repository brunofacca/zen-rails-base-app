require 'rails_helper'

RSpec.describe User, type: :model do
  subject { User }
  let(:user) { FactoryBot.build(:user) }

  it { is_expected.to have_a_valid_factory }

  # Email presence and uniqueness validations are Devise's responsibility.
  # No need to test them here.
  it { is_expected.to be_invalid_without_a(:first_name) }
  it { is_expected.to be_invalid_without_a(:last_name) }

  it { is_expected.to find_records_by_slug }

  describe '#password' do
    let(:user) do
      FactoryBot.build(:user,
                        password: password,
                        password_confirmation: password)
    end
    let(:expected_error) do
      I18n.t 'activerecord.errors.models.user.attributes.password.weak_password'
    end
    before(:each) { user.valid? }

    context 'with less than 8 characters' do
      let(:password) { 'FooB4r!' }
      it 'is invalid' do
        expect(user.errors[:password]).to include(expected_error)
      end
    end

    context 'without at least one digit' do
      let(:password) { 'FooBarBaz!' }
      it 'is invalid' do
        expect(user.errors[:password]).to include(expected_error)
      end
    end

    context 'without at least one uppercase and one lower casse letter' do
      let(:password) { 'foob4rbaz!' }
      it 'is invalid' do
        expect(user.errors[:password]).to include(expected_error)
      end
    end
  end

  it 'has a default role of :user' do
    expect(user).to be_a_user
  end

  it "returns the user's full name as a string" do
    expect(user.full_name).to eq "#{user.first_name} #{user.last_name}"
  end
end
