# frozen_string_literal: false

require_relative 'helpers/spec_helper'
require_relative 'helpers/vcr_helper'
require_relative 'helpers/database_helper'

describe 'Integration Tests of Github API and Database' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_github
    DatabaseHelper.wipe_database
  end

  after do
    VcrHelper.eject_vcr
    DatabaseHelper.wipe_database
  end

  it 'Happy: should be able to save resourece & topics from Github to database' do
    resource = MindMap::Github::ResourceMapper
                .new(GITHUB_TOKEN)
                .search(DB_TEST_SEARCH_QUERY, DB_TEST_TOPICS)

    rebuilt = MindMap::Repository::For.entity(resource).find_or_create(resource)
    _(rebuilt.origin_id).must_equal(resource.origin_id)
    _(rebuilt.name).must_equal(resource.name)
    _(rebuilt.description).must_equal(resource.description)
    _(rebuilt.github_url).must_equal(resource.github_url)
    _(rebuilt.homepage).must_equal(resource.homepage)
    _(rebuilt.language).must_equal(resource.language)
    _(rebuilt.topics.count).must_equal(resource.topics.count)
  end
end
