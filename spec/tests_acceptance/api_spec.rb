# frozen_string_literal: true

require_relative '../helpers/spec_helper'
require_relative '../helpers/vcr_helper'
require_relative '../helpers/database_helper'
require 'rack/test'

def app
  MindMap::App
end

describe 'Test API routes' do
  include Rack::Test::Methods

  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_github
    DatabaseHelper.wipe_database
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Root route' do
    it 'should successfully return root information' do
      get '/'

      _(last_response.status).must_equal 200

      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'ok'
      _(body['message']).must_include 'api/v1'
    end
  end

  describe 'Add inboxes route' do
    it 'should be able to add an inbox' do
      post 'api/v1/inboxes', INBOX

      _(last_response.status).must_equal 201

      resource = JSON.parse last_response.body
      _(resource['id']).wont_be_nil
      _(resource['name']).must_equal INBOX[:name]
      _(resource['description']).must_equal INBOX[:description]
      _(resource['url']).must_equal INBOX[:url]

      inbox = MindMap::Representer::Inbox.new(
        MindMap::Response::OpenStructWithLinks.new
      ).from_json last_response.body

      _(inbox.links['self'].href).must_include 'http'
    end

    it 'should report an error when an inbox with a given id already exists' do
      new_inbox = MindMap::Entity::Inbox.new(id: nil,
                                             name: 'Test Inbox',
                                             url: INBOX[:url],
                                             description: 'A test inbox',
                                             suggestions: [],
                                             documents: [])
      MindMap::Repository::For.klass(MindMap::Entity::Inbox).create(new_inbox)

      post 'api/v1/inboxes', INBOX

      _(last_response.status).must_equal 422

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'already exists'
    end

    it 'should report an error when the inbox_url is an invalid format' do
      post 'api/v1/inboxes', INBOX.merge(url: '1234')

      _(last_response.status).must_equal 400

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'Unsupported'
    end
  end

  describe 'Get inboxes route' do
    it 'should return a the requested inbox' do
      new_inbox = MindMap::Entity::Inbox.new(id: nil,
                                             name: 'Test Inbox',
                                             url: GOOD_INBOX_ID,
                                             description: 'A test inbox',
                                             suggestions: [],
                                             documents: [])
      saved_inbox = MindMap::Repository::For.klass(MindMap::Entity::Inbox).create(new_inbox)

      get "/api/v1/inboxes/#{saved_inbox.url}"

      _(last_response.status).must_equal 201

      inbox = JSON.parse last_response.body

      _(inbox['id']).wont_be_nil
      _(inbox['name']).must_equal saved_inbox.name
      _(inbox['description']).must_equal saved_inbox.description
      _(inbox['url']).must_equal saved_inbox.url
      _(inbox['suggestions'].count).must_equal 30
    end

    it 'should return an error for invalid inbox' do
      get '/api/v1/inboxes/9999'

      _(last_response.status).must_equal 404

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'not'
    end
  end

  describe 'Add documents route' do
    it 'should be able to add a document' do
      post 'api/v1/documents', { html_url: PROJECT_URL }

      _(last_response.status).must_equal 201

      document = JSON.parse last_response.body
      _(document['id']).wont_be_nil
      _(document['name']).must_equal CORRECT['document_name']
      _(document['html_url']).must_equal CORRECT['document_html_url']
      _(document['description']).must_equal CORRECT['document_description']

      doc = MindMap::Representer::Document.new(
        MindMap::Response::OpenStructWithLinks.new
      ).from_json last_response.body

      _(doc.links['self'].href).must_include 'http'
    end

    it 'should report error when the document is invalid' do
      post 'api/v1/documents', { html_url: 'https://github.com/derrxb/invalid' }

      _(last_response.status).must_equal 404

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'not'
    end
  end

  describe 'Get documents route' do
    it 'should return the requested documents' do
      html_url = MindMap::Request::AddDocument.new({ 'html_url' => PROJECT_URL }) # Ensures a string as hash key is used.
      result = MindMap::Service::AddDocument.new.call(html_url: html_url).value!.message.id

      get "/api/v1/documents/#{result}"

      _(last_response.status).must_equal 200

      document = JSON.parse last_response.body

      _(document['id']).wont_be_nil
      _(document['name']).must_equal CORRECT['document_name']
      _(document['html_url']).must_equal CORRECT['document_html_url']
      _(document['description']).must_equal CORRECT['document_description']
    end

    it 'should return an error for invalid documents' do
      get '/api/v1/documents/9999'

      _(last_response.status).must_equal 404

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'not'
    end
  end

  describe 'Get inbox documents route' do
    it 'should return an empty list when no documents exists' do
      inbox_params = MindMap::Request::AddInbox.new({ 'url' => GOOD_INBOX_ID,
                                                      'name' => 'test',
                                                      'description' => 'test' })
      inbox = MindMap::Service::AddInbox.new.call(params: inbox_params).value!.message

      get "api/v1/inboxes/#{inbox.url}/documents"

      _(last_response.status).must_equal 200
      response = JSON.parse(last_response.body)

      documents = response['documents']
      _(documents.count).must_equal 0
    end

    it 'should return an documents lists when they exists for an inbox' do
      inbox_params = MindMap::Request::AddInbox.new({ 'url' => GOOD_INBOX_ID,
                                                      'name' => 'test',
                                                      'description' => 'test' })
      inbox = MindMap::Service::AddInbox.new.call(params: inbox_params).value!.message

      get "api/v1/inboxes/#{inbox.url}/documents"

      _(last_response.status).must_equal 200
      response = JSON.parse(last_response.body)

      documents = response['documents']
      _(documents.count).must_equal 1
    end
  end

  describe 'Save inbox suggestion route' do
    it 'should save the suggestion to the inbox'
  end

  describe 'Discard inbox suggestion route' do
    it 'should remove suggestion from the inbox'
  end
end
