# frozen_string_literal: true
require 'shellwords'

class Benefits < ApplicationRecord

  def self.save(file, backup = false)
    data_path = Rails.root.join("public", "data")
    # Sanitize filename to prevent path traversal and other security issues
    sanitized_filename = sanitize_filename(file.original_filename)
    full_file_name = "#{data_path}/#{sanitized_filename}"
    f = File.open(full_file_name, "wb+")
    f.write file.read
    f.close
    make_backup(file, data_path, full_file_name, sanitized_filename) if backup == "true"
  end

  def self.make_backup(file, data_path, full_file_name, sanitized_filename)
    if File.exist?(full_file_name)
      backup_filename = "#{data_path}/bak#{Time.zone.now.to_i}_#{sanitized_filename}"
      silence_streams(STDERR) { system("cp", full_file_name, backup_filename) }
    end
  end

  def self.sanitize_filename(filename)
    # Remove path separators and other potentially dangerous characters
    # Keep only alphanumeric characters, dots, hyphens, and underscores
    sanitized = filename.gsub(/[^a-zA-Z0-9.\-_]/, '_')
    # Ensure filename doesn't start with a dot (hidden files)
    sanitized = sanitized.gsub(/^\.+/, '')
    # Limit length to prevent issues
    sanitized = sanitized[0, 255] if sanitized.length > 255
    # Ensure we have a non-empty filename
    sanitized.empty? ? 'unnamed_file' : sanitized
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
