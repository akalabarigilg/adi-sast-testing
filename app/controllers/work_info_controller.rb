# frozen_string_literal: true
class WorkInfoController < ApplicationController
  def index
    @user = User.find_by(id: params[:user_id])
    if !(@user) || @user.admin
      flash[:error] = "Sorry, no user with that user id exists"
      redirect_to home_dashboard_index_path
    elsif @user != current_user && !is_admin?
      flash[:error] = "Access denied. You can only view your own work information."
      redirect_to home_dashboard_index_path
    end
  end

end
