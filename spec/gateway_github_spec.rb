# frozen_string_literal: false

require_relative 'spec_helper'
require_relative 'helpers/vcr_helper'

describe 'Tests Github API library' do
  before do
    VcrHelper.configure_vcr_for_github
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Search Query' do
    it 'Ensures that the correct parameters are returned' do
      resource =
        MindMap::Github::ResourceMapper
        .new(GITHUB_TOKEN)
        .search(SEARCH_QUERY, TOPICS)
      _(resource.name).must_equal CORRECT['name']
      _(resource.homepage).must_equal CORRECT['homepage']
      _(resource.description).must_equal CORRECT['description']
      _(resource.language).must_equal CORRECT['language']
    end

    it 'Ensures that an exception is raised when the query is too long' do
      _(proc do
        MindMap::Github::ResourceMapper
          .new(GITHUB_TOKEN)
          .search(INVALID_SEARCH_QUERY, TOPICS)
      end).must_raise MindMap::Github::Api::Response::UnprocessableEntity
    end

    it 'Ensures that an exception is raised when the token is invalid' do
      _(proc do
        MindMap::Github::ResourceMapper
          .new('BAD_TOKEN')
          .search(SEARCH_QUERY, TOPICS)
      end).must_raise MindMap::Github::Api::Response::Unauthorized
    end
  end

  describe 'Topic Information' do
    before do
      @resource = MindMap::Github::ResourceMapper
                  .new(GITHUB_TOKEN)
                  .search(SEARCH_QUERY, TOPICS)
    end

    it 'Ensures topics are formatted correct' do
      @resource.topics.each do |topic|
        _(topic).must_be_kind_of(MindMap::Entity::Topic)
      end
    end

    it 'Ensure that the topic names are correct' do
      topics = @resource.topics
      _(@resource.topics.count).must_equal CORRECT['topics'].count

      topicnames = topics.map(&:name)
      _(topicnames).must_equal CORRECT['topics']
    end
  end
end
