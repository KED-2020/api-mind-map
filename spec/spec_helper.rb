# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'simplecov'
SimpleCov.start
require 'vcr'
require 'webmock'
require 'yaml'
require_relative '../lib/github_api'

CORRECT = YAML.safe_load(File.read("#{__dir__}/fixtures/github_results.yml"))
ACCESS_TOKEN = YAML.safe_load(File.read("#{__dir__}/../config/secrets.yml"))['GITHUB_TOKEN']

TOPICS = %w[tensorflow natural-language-processing].freeze
SEARCH_QUERY = 'pytorch-transformers in:readme'
INVALID_SEARCH_QUERY = 10.times.map { ('a'..'z').to_a }.join

CASSETTES_FOLDER = 'fixtures/cassettes'
CASSETTE_FILE = 'github_api'
