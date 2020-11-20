# frozen_string_literal: true

require_relative 'helpers/pec_helper'
require_relative 'helpers/vcr_helper'
require_relative 'helpers/database_helper'

describe 'Test Inboxes Mappers and Repository' do
  DatabaseHelper.setup_database_cleaner

  before do
    DatabaseHelper.wipe_database
    VcrHelper.configure_vcr_for_github
  end

  after do
    VcrHelper.eject_vcr
  end

  it 'HAPPY: should return null when no inbox for the given url exists' do
    inbox = MindMap::Repository::Inbox::For.klass(MindMap::Entity::Inbox)
                                           .find_url('invalid_url')

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
      suggestions: [MindMap::Entity::Suggestion.new(
        id: nil,
        name: 'test',
        description: 'test desc',
        source: 'https://github.com',
        created_at: Time.new
      )]
    )
    saved_inbox = MindMap::Repository::Inbox::For.klass(MindMap::Entity::Inbox)
                                                 .find_or_create(inbox)

    saved_suggestions = MindMap::Mapper::Inbox.new(saved_inbox).suggestions

    _(saved_suggestions.count).must_equal 1
    _(saved_suggestions[0].name).must_equal 'test'
    _(saved_suggestions[0].description).must_equal 'test desc'
    _(saved_suggestions[0].source).must_equal 'https://github.com'
  end
end
