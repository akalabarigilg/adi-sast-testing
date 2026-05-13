# frozen_string_literal: true
module Encryption

  # Added a re-usable encryption routine with proper IV handling
  def self.encrypt_sensitive_value(val = "")
     aes = OpenSSL::Cipher.new(cipher_type)
     aes.encrypt
     aes.key = key[0..31]
     # Generate a random IV for each encryption
     random_iv = aes.random_iv
     aes.iv = random_iv
     encrypted_data = aes.update("#{val}") + aes.final
     # Prepend IV to encrypted data before base64 encoding
     iv_and_encrypted = random_iv + encrypted_data
     Base64.strict_encode64(iv_and_encrypted).encode("utf-8")
  end

  def self.decrypt_sensitive_value(val = "")
     aes = OpenSSL::Cipher.new(cipher_type)
     aes.decrypt
     aes.key = key[0..31]
     decoded = Base64.strict_decode64("#{val}")
     # Extract IV from the beginning of the decoded data
     iv_length = 16  # AES block size
     extracted_iv = decoded[0...iv_length]
     encrypted_data = decoded[iv_length..-1]
     aes.iv = extracted_iv
     aes.update(encrypted_data) + aes.final
  end

  # Use proper key derivation instead of hard-coded keys
  def self.key
    # Use environment variable or generate from a secure source
    if Rails.env.production?
      # In production, use environment variable
      raise "ENCRYPTION_KEY environment variable not set" unless ENV['ENCRYPTION_KEY']
      ENV['ENCRYPTION_KEY']
    else
      # In development/test, use a derived key from a base secret
      # This is still not ideal but better than hard-coded constants
      base_secret = Rails.application.secret_key_base || "fallback_secret_for_development"
      OpenSSL::PKCS5.pbkdf2_hmac_sha1(base_secret, "encryption_salt", 10000, 32)
    end
  end

  def self.cipher_type
    "aes-256-cbc"
  end

end
