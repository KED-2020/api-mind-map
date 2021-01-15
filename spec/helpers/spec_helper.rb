# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'
require 'minitest/autorun'
require 'minitest/rg'

require_relative '../../init'

GITHUB_TOKEN = MindMap::App.config.GITHUB_TOKEN

CORRECT = YAML.safe_load(File.read("#{__dir__}/../fixtures/github_results.yml"))

SEARCH_QUERY = 'pytorch-transformers in:readme'
TOPICS = %w[tensorflow natural-language-processing].freeze

INVALID_SEARCH_QUERY = 10.times.map { ('a'..'z').to_a }.join

DB_TEST_SEARCH_QUERY = 'bitcoin'
DB_TEST_TOPICS = %w[python].freeze

# Helper methods
def homepage
  MindMap::App.config.APP_HOST
end
GOOD_INBOX_URL = 'wonderful-time-alone'
SAD_INBOX_URL = 'wonderful-time-alone'
BAD_INBOX_URL = 'foo123'
SUGGESTION_NAMES = %w[tensorflow TensorFlow TensorFlow-Examples].freeze

GOOD_KEYWORDS_LIST = %w[Bitcoin].freeze
BAD_KEYWORDS_LIST = %w[Bitcoin Python Crypto Random Random Random].freeze

PROJECT_OWNER = 'derrxb'
PROJECT_NAME = 'derrxb'
PROJECT_URL = 'https://github.com/derrxb/derrxb'

INBOX = {
  name: 'Test Inbox',
  description: 'Test Inbox Description',
  url: GOOD_INBOX_URL
}.freeze
