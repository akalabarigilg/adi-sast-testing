# frozen_string_literal: true
# Use environment variable for API token secret, fallback to secure random for development
ACCESS_TOKEN_SECRET = ENV['API_TOKEN_SECRET'] || Rails.application.secret_key_base

RG_IV = "PPKLKAJDKGHALDJL482823458028"
