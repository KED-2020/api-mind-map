# frozen_string_literal: true

folders = %w[entities repositories]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
