# frozen_string_literal: true

require 'vcr'
require 'webmock'

# Set up VCR
class VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'
  CASSETTE_FILE = 'github_api'

  def self.setup_vcr
    VCR.configure do |config|
      config.cassette_library_dir = CASSETTES_FOLDER
      config.hook_into :webmock
      config.ignore_localhost = true
    end
  end

  def self.configure_vcr_for_github(recording: :new_episodes)
    VCR.configure do |config|
      config.filter_sensitive_data('<GITHUB_TOKEN>') { GITHUB_TOKEN }
      config.filter_sensitive_data('<GITHUB_TOKEN_ESC>') { CGI.escape(GITHUB_TOKEN) }
    end

    VCR.insert_cassette(
      CASSETTE_FILE,
      record: :new_episodes,
      match_requests_on: %i[method uri headers],
      allow_playback_repeats: true
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
