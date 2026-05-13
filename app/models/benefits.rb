# frozen_string_literal: true
class Benefits < ApplicationRecord

  # Maximum file size in bytes (10MB)
  MAX_FILE_SIZE = 10.megabytes
  
  # Allowed file extensions
  ALLOWED_EXTENSIONS = %w[.pdf .doc .docx .txt .jpg .jpeg .png .gif].freeze
  
  def self.save(file, backup = false)
    # Validate file size
    if file.size > MAX_FILE_SIZE
      raise "File size exceeds maximum allowed size of #{MAX_FILE_SIZE / 1.megabyte}MB"
    end
    
    # Sanitize and validate filename
    sanitized_filename = sanitize_filename(file.original_filename)
    validate_file_extension(sanitized_filename)
    
    # Use uploads directory outside of public to prevent direct web access
    data_path = Rails.root.join("uploads", "data")
    FileUtils.mkdir_p(data_path) unless Dir.exist?(data_path)
    
    full_file_name = File.join(data_path, sanitized_filename)
    
    # Write file securely
    File.open(full_file_name, "wb+") do |f|
      f.write file.read
    end
    
    make_backup(sanitized_filename, data_path, full_file_name) if backup == "true"
  end

  def self.make_backup(sanitized_filename, data_path, full_file_name)
    if File.exist?(full_file_name)
      backup_filename = "bak#{Time.zone.now.to_i}_#{sanitized_filename}"
      backup_path = File.join(data_path, backup_filename)
      
      # Use FileUtils.cp instead of system call to avoid command injection
      FileUtils.cp(full_file_name, backup_path)
    end
  end
  
  private
  
  def self.sanitize_filename(filename)
    # Remove any path components to prevent directory traversal
    basename = File.basename(filename)
    
    # Remove or replace dangerous characters
    sanitized = basename.gsub(/[^a-zA-Z0-9\-_\.]/, '_')
    
    # Ensure filename is not empty and doesn't start with dot
    sanitized = 'file' if sanitized.empty? || sanitized.start_with?('.')
    
    # Limit filename length
    sanitized = sanitized[0..100] if sanitized.length > 100
    
    sanitized
  end
  
  def self.validate_file_extension(filename)
    extension = File.extname(filename).downcase
    unless ALLOWED_EXTENSIONS.include?(extension)
      raise "File extension '#{extension}' is not allowed. Allowed extensions: #{ALLOWED_EXTENSIONS.join(', ')}"
    end
  end

  def self.silence_streams(*streams)
    on_hold = streams.collect { |stream| stream.dup }
    streams.each do |stream|
      stream.reopen(RUBY_PLATFORM =~ /mswin/ ? "NUL:" : "/dev/null")
      stream.sync = true
    end
    yield
  ensure
    streams.each_with_index do |stream, i|
      stream.reopen(on_hold[i])
    end
  end
end
