# frozen_string_literal: true
class BenefitFormsController < ApplicationController

  def index
    @benefits = Benefits.new
  end

  def download
   begin
     path = params[:name]
     file = params[:type].constantize.new(path)
     send_file file, disposition: "attachment"
   rescue
     redirect_to user_benefit_forms_path(user_id: current_user.id)
   end
  end

  def upload
    file = params[:benefits][:upload]
    if file
      begin
        Benefits.save(file, params[:benefits][:backup])
        flash[:success] = "File Successfully Uploaded!"
      rescue => e
        flash[:error] = "Upload failed: #{e.message}"
      end
    else
      flash[:error] = "No file selected"
    end
    redirect_to user_benefit_forms_path(user_id: current_user.id)
  end

end
