# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'

describe 'GetInbox integration tests' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_github(recording: :none)
    DatabaseHelper.wipe_database
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Get an Inbox' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should return inbox and their suggestions' do
      # GIVEN: an inbox with suggestions exist
      inbox = MindMap::Entity::Inbox.new(id: nil,
                                         name: 'test',
                                         url: GOOD_INBOX_URL,
                                         description: 'test',
                                         suggestions: [],
                                         documents: [])

      saved_inbox = MindMap::Repository::For.klass(MindMap::Entity::Inbox).find_or_create(inbox)

      # WHEN: we request an inbox and its suggestions
      inbox_url = MindMap::Request::EncodedInboxId.new(saved_inbox.url)
      result = MindMap::Service::GetInbox.new.call(inbox_url: inbox_url)

      # THEN: we should see our inbox with its suggestions
      _(result.success?).must_equal true
      inbox_result = result.value!.message
      _(inbox_result.name).must_equal inbox.name
      _(inbox_result.description).must_equal inbox.description
      _(inbox_result.suggestions.count).must_equal 30
    end

    it 'SAD: should not return inbox if it does not exist' do
      # GIVEN: an inbox that does not exist
      # WHEN: we request an inbox and its suggestions
      inbox_url = MindMap::Request::EncodedInboxId.new(SAD_inbox_url)
      result = MindMap::Service::GetInbox.new.call(inbox_url: inbox_url)

      # Then: we should get failure
      _(result.failure?).must_equal true
    end
  end
end
