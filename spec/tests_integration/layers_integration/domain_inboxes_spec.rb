# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'

describe 'Test Inboxes Mappers and Repository' do
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

  it 'HAPPY: should return null when no inbox for the given url exists' do
    inbox = MindMap::Repository::For.klass(MindMap::Entity::Inbox).find_by_url('invalid_url')

    assert_nil(inbox)
  end

  # I think this is more of a unit test for for the mapper + repository
  it 'HAPPY: ensures that mapper returns the right suggestions for an inbox' do
    # This recreates the work that the mapper would do by giving a suggestion to an inbox.
    # We have yet to write the suggestion engine so that's why we're doing it this way.
    inbox = MindMap::Entity::Inbox.new(
      id: nil,
      name: 'test',
      url: '12345',
      description: 'test',
      suggestions: [],
      documents: [],
      subscriptions: []
    )
    saved_inbox = MindMap::Repository::For.klass(MindMap::Entity::Inbox).find_or_create(inbox)

    suggestions = MindMap::Mapper::Inbox.new(GITHUB_TOKEN).suggestions()
    MindMap::Repository::Inboxes.add_suggestions(saved_inbox, suggestions)

    # This test case is more friendly for Hurb Display
    _(suggestions.count).must_equal 30
    _(suggestions[0].name).must_equal "tensorflow"
    _(suggestions[0].description).must_equal "An Open Source Machine Learning Framework for Everyone"
    _(suggestions[0].html_url).must_equal "https://github.com/tensorflow/tensorflow"
  end
end
