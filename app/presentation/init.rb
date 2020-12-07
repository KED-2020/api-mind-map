# frozen_string_literal: true

folders = %w[representers responses]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
