# frozen_string_literal: true

folders = %w[infrastructure application domain presentation]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
