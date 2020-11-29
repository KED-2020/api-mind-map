# frozen_string_literal: true

folders = %w[models infrastructure application domain presentation]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
