# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'yaml'
require 'minitest/autorun'
require 'minitest/rg'

require_relative '../init'

ENV['RACK_ENV'] = 'test'

GITHUB_TOKEN = MindMap::App.config.GITHUB_TOKEN

CORRECT = YAML.safe_load(File.read("#{__dir__}/fixtures/github_results.yml"))

TOPICS = %w[tensorflow natural-language-processing].freeze
SEARCH_QUERY = 'pytorch-transformers in:readme'
INVALID_SEARCH_QUERY = 10.times.map { ('a'..'z').to_a }.join