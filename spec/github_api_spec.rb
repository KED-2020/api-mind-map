# frozen_string_literal: false

require_relative 'spec_helper'

describe 'Tests Github API library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<GITHUB_TOKEN>') { ACCESS_TOKEN }
    c.filter_sensitive_data('<GITHUB_TOKEN_ESC>') { CGI.escape(ACCESS_TOKEN) }
  end

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Search Query' do
    it 'Ensures that the correct parameters are returned' do
      resource = MindMap::GitHubApi.new(ACCESS_TOKEN).resource(SEARCH_QUERY, TOPICS)

      _(resource.name).must_equal CORRECT['name']
      _(resource.homepage).must_equal CORRECT['homepage']
      _(resource.description).must_equal CORRECT['description']
      _(resource.language).must_equal CORRECT['language']
    end

    it 'Ensures that an exception is raised when the query is too long' do
      _(proc do
        MindMap::GitHubApi.new(ACCESS_TOKEN).resource(INVALID_SEARCH_QUERY, TOPICS)
      end).must_raise MindMap::GitHubApi::Response::UnprocessableEntity
    end

    it 'Ensures that an exception is raised when the token is invalid' do
      _(proc do
        MindMap::GitHubApi.new('BAD_TOKEN').resource(SEARCH_QUERY, TOPICS)
      end).must_raise MindMap::GitHubApi::Response::Unauthorized
    end
  end

  describe 'Topic Information' do
    before do
      @resource = MindMap::GitHubApi.new(ACCESS_TOKEN).resource(SEARCH_QUERY, TOPICS)
    end

    it 'Ensures topics are formatted correct' do
      @resource.topics.each do |topic|
        _(topic).must_be_kind_of(MindMap::Topic)
      end
    end

    it 'Ensure that the topic names are correct' do
      topics = @resource.topics

      _(@resource.topics.count).must_equal CORRECT['topics'].count

      usernames = topics.map(&:name)
      correct_usernames = CORRECT['topics'].map { |topic| topic }
      _(usernames).must_equal correct_usernames
    end
  end
end
