# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative '../init'
require_relative 'helpers/database_helper'

DatabaseHelper.setup_database_cleaner
DatabaseHelper.wipe_database    # Clean every time

GITHUB_TOKEN = MindMap::App.config.GITHUB_TOKEN


########################################################################
# Test Data: /inbox/12345 (Test Inbox)
########################################################################
inbox = MindMap::Entity::Inbox.new(
  id: nil,
  name: 'Test Inbox',
  url: '12345',
  description: 'A test inbox which contains some suggestions from searching tensorflow from GitHub',
  suggestions: [])
saved_inbox = MindMap::Repository::Inbox::For.klass(MindMap::Entity::Inbox).find_or_create(inbox)

# Load some hard code suggestions as test data in Inbox/12345
suggestions = MindMap::Mapper::Inbox.new(GITHUB_TOKEN).suggestions()
MindMap::Repository::Inboxes.add_suggestions(saved_inbox, suggestions)


########################################################################
# Test Data: /inbox/guest-inbox (Guest Inbox)
########################################################################
guest_inbox = MindMap::Entity::Inbox.new(
  id: nil,
  name: 'Guest Inbox',
  url: 'guest-inbox',
  description: 'Guest Inbox reserve your inbox data by cookie, you can delete your cookie if you want.',
  suggestions: [])
saved_guest_inbox = MindMap::Repository::Inbox::For.klass(MindMap::Entity::Inbox).find_or_create(guest_inbox)

# No suggestions in Guest Inbox


########################################################################
# Test Data: /inbox (New Inbox)
########################################################################
new_inbox = MindMap::Entity::Inbox.new(
  id: nil,
  name: 'New Inbox',
  url: '',
  description: 'No suggestions in your New Inbox.',
  suggestions: [])
saved_new_inbox = MindMap::Repository::Inbox::For.klass(MindMap::Entity::Inbox).find_or_create(new_inbox)

# No suggestions in New Inbox


# DatabaseHelper.wipe_database    # Kept as test data