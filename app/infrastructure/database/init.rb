# frozen_string_literal: true

folders = %w[]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
