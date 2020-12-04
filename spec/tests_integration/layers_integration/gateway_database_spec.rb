# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'

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

  it 'Happy: should be able to save document & topics from Github to database' do
    document = MindMap::Github::DocumentsMapper
                .new(GITHUB_TOKEN)
                .search(DB_TEST_SEARCH_QUERY, DB_TEST_TOPICS)

    rebuilt = MindMap::Repository::For.entity(document).find_or_create(document)
    _(rebuilt.origin_id).must_equal(document.origin_id)
    _(rebuilt.name).must_equal(document.name)
    _(rebuilt.description).must_equal(document.description)
    _(rebuilt.html_url).must_equal(document.html_url)
    _(rebuilt.topics.count).must_equal(document.topics.count)
  end
end
