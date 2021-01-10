# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/database_helper'

describe 'Add Inbox Integration Test' do
  DatabaseHelper.setup_database_cleaner

  before do
    DatabaseHelper.wipe_database
  end

  it 'HAPPY: should add an inbox if the right parameters are given' do
    # GIVEN: valid parameters for an inbox
    params = MindMap::Request::AddInbox.new({
                                              'url' => GOOD_INBOX_URL,
                                              'name' => 'Test',
                                              'description' => 'Test'
                                            })

    # WHEN: the service is called with the request object
    result = MindMap::Service::AddInbox.new.call(params: params)

    # THEN: the inbox should be saved correctly
    _(result.success?).must_equal true

    inbox = result.value!.message

    _(inbox.name).must_equal('Test')
    _(inbox.description).must_equal('Test')
    _(inbox.url).must_equal(GOOD_INBOX_URL)
  end

  it 'BAD: should not add an inbox if an invalid `url` is given' do
    # GIVEN: an invalid `url` parameter for the inbox
    params = MindMap::Request::AddInbox.new({
                                              'url' => BAD_INBOX_URL,
                                              'name' => 'Test',
                                              'description' => 'Test'
                                            })

    # WHEN: the service is called with teh request object
    result = MindMap::Service::AddInbox.new.call(params: params)

    # THEN: the inbox should be saved correctly
    _(result.success?).must_equal false
    _(result.failure.message).must_include 'Unsupported url format'
  end
end
