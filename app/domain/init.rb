# frozen_string_literal: true

folders = %w[inboxes]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end