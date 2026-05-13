# frozen_string_literal: true
ACCESS_TOKEN_SALT = ENV['ACCESS_TOKEN_SALT'] || raise("ACCESS_TOKEN_SALT environment variable is required. Please set a secure salt for token generation.")

RG_IV = ENV['ENCRYPTION_IV'] || raise("ENCRYPTION_IV environment variable is required. Please set a secure initialization vector.")
