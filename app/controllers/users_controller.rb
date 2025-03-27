# frozen_string_literal: true
class UsersController < ApplicationController
  before_action :authenticated, except: [:new, :create]
  before_action :set_user, only: [:update]
  before_action :authorize_user, only: [:update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to home_dashboard_index_path
    else
      flash[:error] = @user.errors.full_messages.to_sentence
      render :new
    end
  end

  def account_settings
    @user = current_user
  end

  def update
    if @user.update(user_params_without_password)
      if params[:user][:password].present? && params[:user][:password] == params[:user][:password_confirmation]
        @user.update(password: params[:user][:password])
      elsif params[:user][:password].present?
        flash[:error] = "Password confirmation does not match"
        redirect_to user_account_settings_path(user_id: current_user.id) and return
      end

      flash[:success] = "User updated successfully"
    else
      flash[:error] = @user.errors.full_messages.to_sentence
    end

    respond_to do |format|
      format.html { redirect_to user_account_settings_path(user_id: current_user.id) }
      format.json { render json: { msg: flash[:success] ? "success" : "false" } }
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation)
  end

  def user_params_without_password
    params.require(:user).permit(:email, :first_name, :last_name)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user
    redirect_to(root_path, alert: "Not authorized!") unless @user == current_user
  end
end
