# frozen_string_literal: true

%w[app config]
  .each do |folder|
    require_relative "#{folder}/init"
  end
