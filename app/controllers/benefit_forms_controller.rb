# frozen_string_literal: true
class BenefitFormsController < ApplicationController

  def index
    @benefits = Benefits.new
  end

  def download
    begin
      # Whitelist of allowed files to prevent path traversal and arbitrary file access
      allowed_files = {
        'Health_n_Stuff.pdf' => 'public/docs/Health_n_Stuff.pdf',
        'Dental_n_Stuff.pdf' => 'public/docs/Dental_n_Stuff.pdf'
      }
      
      # Extract filename from the path parameter
      requested_file = File.basename(params[:name].to_s)
      
      # Check if the requested file is in our whitelist
      if allowed_files.key?(requested_file)
        file_path = Rails.root.join(allowed_files[requested_file])
        
        # Verify the file exists and is readable
        if File.exist?(file_path) && File.readable?(file_path)
          send_file file_path, disposition: "attachment"
        else
          flash[:error] = "File not found or not accessible"
          redirect_to user_benefit_forms_path(user_id: current_user.id)
        end
      else
        flash[:error] = "Access to requested file is not allowed"
        redirect_to user_benefit_forms_path(user_id: current_user.id)
      end
    rescue => e
      Rails.logger.error "File download error: #{e.message}"
      flash[:error] = "An error occurred while downloading the file"
      redirect_to user_benefit_forms_path(user_id: current_user.id)
    end
  end

  def upload
    file = params[:benefits][:upload]
    if file
      flash[:success] = "File Successfully Uploaded!"
      Benefits.save(file, params[:benefits][:backup])
    else
      flash[:error] = "Something went wrong"
    end
    redirect_to user_benefit_forms_path(user_id: current_user.id)
  end

end
