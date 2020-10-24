require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require_relative '../lib/github_api'

CORRECT = YAML.safe_load(File.read("spec/fixtures/github_results.yml"))
ACCESS_TOKEN = YAML.safe_load(File.read("config/secrets.yml"))['GITHUB_TOKEN']

TOPICS = %w[tensorflow natural-language-processing].freeze
SEARCH_QUERY = 'pytorch-transformers in:readme'.freeze
INVALID_SEARCH_QUERY = 10.times.map { ('a'..'z').to_a }.join