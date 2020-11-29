# frozen_string_literal: true

folders = %w[models infrastructure controllers domain forms presentation]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
