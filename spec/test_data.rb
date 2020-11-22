# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative '../init'
require_relative 'helpers/database_helper'

GITHUB_TOKEN = MindMap::App.config.GITHUB_TOKEN

DatabaseHelper.setup_database_cleaner
DatabaseHelper.wipe_database    # Clean every time

########################################################################
# Test Data: /inbox/12345
########################################################################
inbox = MindMap::Entity::Inbox.new(
  id: nil,
  name: 'test',
  url: '12345',
  description: 'test',
  suggestions: [])
saved_inbox = MindMap::Repository::Inbox::For.klass(MindMap::Entity::Inbox).find_or_create(inbox)

# Load some hard code suggestions as test data in Inbox/12345
suggestions = MindMap::Mapper::Inbox.new(GITHUB_TOKEN).suggestions()
MindMap::Repository::Inboxes.add_suggestions(saved_inbox, suggestions)

########################################################################
# Test Data: /inbox/guest-inbox
########################################################################
inbox = MindMap::Entity::Inbox.new(
  id: nil,
  name: 'Guest',
  url: 'guest-inbox',
  description: 'Guest Inbox reserve your inbox data by cookie, you can delete your cookie if you want.',
  suggestions: [])
saved_inbox = MindMap::Repository::Inbox::For.klass(MindMap::Entity::Inbox).find_or_create(inbox)

# No suggestions in Guest Inbox


# DatabaseHelper.wipe_database    # Kept as test data