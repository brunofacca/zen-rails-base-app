module Admin
  # This controller is for admin use only (user management by admins). The form
  # provided by Devise's registerable module (which allows users to edit their
  # profiles) uses another controller.
  class UsersController < ApplicationController
    helper UsersHelper

    before_action :set_user, only: %i[show edit update destroy]

    # This hack is required to use Pundit with a namespaced controller
    def self.policy_class
      Admin::UserPolicy
    end

    # GET /admin/users
    def index
      # This ivar is not used in the view, only as input to Ransack. There is
      # no need to eager load associations here, Ransack avoids N+1 queries.
      @q = policy_scope(User).ransack(params[:q])
      # Ransack default (initial) sort order
      @q.sorts = 'full_name asc' if @q.sorts.empty?
      # Ransack search/filter results, paginated by Kaminari.
      @users = @q.result.page(params[:page])
    end

    # GET /admin/users/1
    def show
      authorize @user
    end

    # GET /admin/users/new
    def new
      @user = User.new
      authorize @user
    end

    # GET /admin/users/1/edit
    def edit
      authorize @user
    end

    # POST /admin/users
    def create
      @user = User.new(user_params)
      authorize @user

      if @user.save
        redirect_to [:admin, @user], notice: t('.success')
      else
        render :new
      end
    end

    # PATCH/PUT /admin/users/1
    def update
      authorize @user

      # Allow updating the user without changing its password (password field
      # will be blank). Remove the password key of the params hash if it's blank
      # (avoid validation error).
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      if @user.update(user_params)
        # If the user is editing himself, Devise will automatically logout.
        # To avoid asking the user to login, we'll login automatically here.
        bypass_sign_in(@user) if current_user == @user
        redirect_to [:admin, @user], notice: t('.success')
      else
        render :edit
      end
    end

    # DELETE /admin/users/1
    def destroy
      authorize @user

      @user.destroy
      redirect_to admin_users_url, notice: t('.success')
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.friendly.find(params[:id])
    end

    # Strong parameters
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation,
                                   :role, :first_name, :last_name)
    end
  end
end
