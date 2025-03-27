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
        respond_with record.to_json
      else
        render json: { error: 'Record not found' }, status: :not_found
      end
    else
      render json: { error: 'Invalid class parameter' }, status: :bad_request
    end
  end

  def index
    if @model
      respond_with @model.all.to_json
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
end
