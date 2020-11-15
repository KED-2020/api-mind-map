# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'
require 'minitest/autorun'
require 'minitest/rg'

require_relative '../init'

GITHUB_TOKEN = MindMap::App.config.GITHUB_TOKEN

CORRECT = YAML.safe_load(File.read("#{__dir__}/fixtures/github_results.yml"))

SEARCH_QUERY = 'pytorch-transformers in:readme'
TOPICS = %w[tensorflow natural-language-processing].freeze

INVALID_SEARCH_QUERY = 10.times.map { ('a'..'z').to_a }.join

DB_TEST_SEARCH_QUERY = 'bitcoin'
DB_TEST_TOPICS = %w[python].freeze

