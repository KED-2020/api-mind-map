# frozen_string_literal: true

require_relative '../../spec/helpers/spec_helper'

describe 'validate inbox id' do
  it 'HAPPY: should find and return existing inbox in database' do
    # GIVEN: a valid inbox id in the database:
    inbox_find = MindMap::Forms::FindInbox.new.call(inbox_id: GOOD_INBOX_ID)
    _(inbox_find.success?).must_equal true
  end

  it 'BAD: should gracefully fail for invalid inbox id' do
    # GIVEN: an invalid inbox id is formed
    inbox_find = MindMap::Forms::FindInbox.new.call(inbox_id: BAD_INBOX_ID)
    # THEN: the service should report failure with an error message
    _(inbox_find.success?).must_equal false
  end
end
