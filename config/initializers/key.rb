# frozen_string_literal: true
if Rails.env.production?
  # Specify env variable/location/etc. to retrieve key from
  KEY = ENV['ENCRYPTION_KEY'] || raise("ENCRYPTION_KEY environment variable is required in production")
else
  KEY = ENV['ENCRYPTION_KEY'] || raise("ENCRYPTION_KEY environment variable is required. Please set a secure encryption key.")
end
