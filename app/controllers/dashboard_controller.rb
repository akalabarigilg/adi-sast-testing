# frozen_string_literal: true
class DashboardController < ApplicationController
  skip_before_action :has_info
  layout false, only: [:change_graph]

  def home
    @user = current_user

    # See if the user has a font preference
    if params[:font]
      # Whitelist allowed font values to prevent XSS
      allowed_fonts = ['8pt', '10pt', '12pt', '14pt', '16pt', '18pt', '20pt', '100%', '125%', '150%', '175%', '200%', '200%25']
      cookies[:font] = allowed_fonts.include?(params[:font]) ? params[:font] : nil
    end
  end

  def change_graph
    self.try(params[:graph])

    if params[:graph] == "bar_graph"
      render "dashboard/bar_graph"
    else
      @user = current_user
      render "dashboard/pie_charts"
    end
  end
end
