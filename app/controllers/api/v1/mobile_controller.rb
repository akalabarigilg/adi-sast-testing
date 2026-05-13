# frozen_string_literal: true
class Api::V1::MobileController < ApplicationController
  before_action :authenticated
  before_action :mobile_request?
  before_action :set_model, only: [:show, :index]

  respond_to :json

  def show
    if @model
      record = @model.find_by(id: params[:id])
      if record
        # Check authorization for the specific record
        if authorized_for_record?(record)
          render json: record, only: safe_attributes_for_model(@model)
        else
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      else
        render json: { error: 'Record not found' }, status: :not_found
      end
    else
      render json: { error: 'Invalid class parameter' }, status: :bad_request
    end
  end

  def index
    if @model
      # Add pagination to prevent large data exposure
      page = params[:page]&.to_i || 1
      per_page = [params[:per_page]&.to_i || 20, 100].min # Cap at 100 records
      
      records = @model.limit(per_page).offset((page - 1) * per_page)
      
      # Filter records based on authorization
      authorized_records = records.select { |record| authorized_for_record?(record) }
      
      render json: authorized_records, only: safe_attributes_for_model(@model)
    else
      render json: { error: 'Invalid class parameter' }, status: :bad_request
    end
  end

  private

  def mobile_request?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /ios|android/i
    end
  end

  def set_model
    if params[:class]
      allowed_classes = %w[AllowedModel1 AllowedModel2]
      if allowed_classes.include?(params[:class])
        @model = params[:class].constantize
      else
        @model = nil
      end
    end
  end

  # Define safe attributes for each allowed model to prevent sensitive data exposure
  def safe_attributes_for_model(model)
    case model.name
    when 'AllowedModel1'
      [:id, :name, :description, :created_at]
    when 'AllowedModel2'
      [:id, :title, :status, :updated_at]
    else
      [:id] # Fallback to only ID for unknown models
    end
  end

  # Authorization check for individual records
  # This should be implemented based on your application's authorization logic
  def authorized_for_record?(record)
    # Example implementation - replace with your actual authorization logic
    # For now, allowing all records but this should be customized
    # based on user permissions, ownership, etc.
    true
  end
end
