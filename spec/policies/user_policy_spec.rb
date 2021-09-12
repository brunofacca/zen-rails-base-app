require 'rails_helper'

describe UserPolicy do
  let!(:ordinary_user) { FactoryBot.create(:user) }
  let!(:admin_user) { FactoryBot.create(:admin_user) }

  describe 'scope' do
    subject(:policy_scope) do
      # The user variable is set within each example group.
      UserPolicy::Scope.new(user, User.all).resolve
    end

    # Users with :user see no records
    context 'given a user with :user role' do
      let(:user) { ordinary_user }
      it 'do not list any users' do
        expect(policy_scope).to eq []
      end
    end

    context 'given a user with :admin role' do
      let(:user) { admin_user }
      it 'lists all users' do
        expect(policy_scope).to include(ordinary_user, admin_user)
      end
    end
  end

  describe 'policies' do
    subject { UserPolicy.new(logged_in_user, record) }
    # Pundit policies take a model instead of a record when there isn't a
    # record (e.g., within the #new action)
    let(:record) { User }

    context 'given an unauthenticated user' do
      let(:logged_in_user) { nil }

      %i[new create show edit update destroy].each do |method|
        it { is_expected.not_to permit(method) }
      end
    end

    context 'given a user with :user role' do
      let(:logged_in_user) { ordinary_user }

      %i[new create show edit update destroy].each do |method|
        it { is_expected.not_to permit(method) }
      end
    end

    context 'given a user with :admin role' do
      let(:logged_in_user) { admin_user }

      %i[new create show edit update destroy].each do |method|
        it { is_expected.to permit(method) }
      end
    end
  end
end
