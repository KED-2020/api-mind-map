# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'

describe 'Add Document Integration Test' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_github
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store document`' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: a valid requests for a document on GitHub' do
      # GIVEN: a valid url for a github document
      document = MindMap::Github::DocumentMapper
        .new(GITHUB_TOKEN).find("#{PROJECT_OWNER}/#{PROJECT_NAME}")
      html_url = MindMap::Forms::AddDocument.new.call(html_url: PROJECT_URL)

      # WHEN: the service is called with the request form object
      document_made = MindMap::Service::AddDocument.new.call(html_url)

      # THEN: the project should be saved correctly
      _(document_made.success?).must_equal true

      rebuilt = document_made.value!

      _(rebuilt.origin_id).must_equal(document.origin_id)
      _(rebuilt.name).must_equal(document.name)
      _(rebuilt.description).must_equal(document.description)
      _(rebuilt.html_url).must_equal(document.html_url)
      _(rebuilt.topics.count).must_equal(document.topics.count)
    end

    it 'HAPPY: should load existing project from the database' do
      # GIVEN: the url of a project that exists in the database already
      html_url = MindMap::Forms::AddDocument.new.call(html_url: PROJECT_URL)
      document = MindMap::Service::AddDocument.new.call(html_url).value!

      # WHEN: the service is called with the request form object
      document_made = MindMap::Service::AddDocument.new.call(html_url)

      # THEN: the project should be loaded correctly
      _(document_made.success?).must_equal true

      rebuilt = document_made.value!
      _(rebuilt.id).must_equal(document.id)

      _(rebuilt.origin_id).must_equal(document.origin_id)
      _(rebuilt.name).must_equal(document.name)
      _(rebuilt.description).must_equal(document.description)
      _(rebuilt.html_url).must_equal(document.html_url)
      _(rebuilt.topics.count).must_equal(document.topics.count)
    end

    it 'BAD: should fail for invalid GitHub url' do
      # GIVEN: an invalid url request is formed
      BAD_GITHUB_URL = 'http://github.com/random1234512'
      url_request = MindMap::Forms::AddDocument.new.call(html_url: BAD_GITHUB_URL)

      # WHEN: the service is called with the request form object
      document_made = MindMap::Service::AddDocument.new.call(url_request)

      # THEN: the service should report failure with an error message
      _(document_made.success?).must_equal false
      _(document_made.failure.downcase).must_include 'invalid link to'
    end

    it 'SAD: should fail for invalid GitHub url' do
      # GIVEN: an invalid url request is formed
      SAD_GITHUB_URL = 'http://github.com/derrxb/unknown'
      url_request = MindMap::Forms::AddDocument.new.call(html_url: SAD_GITHUB_URL)

      # WHEN: the service is called with the request form object
      document_made = MindMap::Service::AddDocument.new.call(url_request)

      # THEN: the service should report failure with an error message
      _(document_made.success?).must_equal false
      _(document_made.failure.downcase).must_include 'not find'
    end
  end
end
