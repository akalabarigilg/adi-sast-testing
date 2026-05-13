# frozen_string_literal: true
class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticated
  before_action :valid_api_token
  before_action :extrapolate_user

  respond_to :json

  def index
    respond_with @user.admin ? User.all : @user
  end

  def show
    respond_with @user.as_json
  end

  private

  def valid_api_token
    authenticate_or_request_with_http_token do |token, options|
      # TODO :add some functionality to check if the HTTP Header is valid
      if !identify_user(token)
        redirect_to root_url
      end
    end
  end

  def identify_user(token = "")
    # We've had issues with URL encoding, etc. causing issues so just to be safe
    # we will go ahead and unescape the user's token
    unescape_token(token)
    
    # Validate token format and extract components
    return false unless @clean_token =~ /\A(\d+)-([\da-f]+)\z/i
    id = $1
    hash = $2
    
    # Validate that id and hash are present
    return false if id.blank? || hash.blank?

    check_hash(id, hash)
  end

  def check_hash(id, hash)
    # Use HMAC with SHA256 for secure token verification
    expected_digest = OpenSSL::HMAC.hexdigest('SHA256', ACCESS_TOKEN_SECRET, id.to_s)
    # Use constant-time comparison to prevent timing attacks
    ActiveSupport::SecurityUtils.secure_compare(hash.downcase, expected_digest.downcase)
  rescue => e
    # Log the error and return false for any exceptions during verification
    Rails.logger.error "Token verification error: #{e.message}"
    false
  end

  # We had some issues with the token and url encoding...
  # this is an attempt to normalize the data.
  def unescape_token(token = "")
    @clean_token = CGI::unescape(token)
  end

  # Added a method to make it easy to figure out who the user is.
  def extrapolate_user
    @user = User.find_by_id(@clean_token.split("-").first)
  end
end
