# frozen_string_literal: true
# Key management is now handled in lib/encryption.rb
# This file is kept for backward compatibility but the hard-coded KEY constant is removed
# In production, set the ENCRYPTION_KEY environment variable
# In development/test, keys are derived from Rails.application.secret_key_base
