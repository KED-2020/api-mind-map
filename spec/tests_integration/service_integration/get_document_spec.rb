# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'

describe 'GetDocument Service Integration Test' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    DatabaseHelper.wipe_database
    VcrHelper.configure_vcr_for_github(recording: :none)
  end

  after do
    VcrHelper.eject_vcr
  end

  it 'HAPPY: returns a document when it exists' do
    # GIVEN: a document that exists in the database
    # html_url = MindMap::Request::AddDocument.new({ 'html_url' => PROJECT_URL }) # Ensures a string as hash key is used.
    # result = MindMap::Service::AddDocument.new.call(html_url: html_url)


    gh_document = MindMap::Github::DocumentMapper
                  .new(GITHUB_TOKEN)
                  .find("#{PROJECT_OWNER}/#{PROJECT_NAME}")
    db_document = MindMap::Repository::For.entity(gh_document)
                                          .create(gh_document)

    # WHEN: we request that document by its ID
    result = MindMap::Service::GetDocument.new.call(document_id: db_document.id)

    # THEN: we should get the requested document
    _(result.success?).must_equal true
    document = result.value!.message
    _(document.origin_id).must_equal gh_document.origin_id
    _(document.html_url).must_equal gh_document.html_url
  end
end
