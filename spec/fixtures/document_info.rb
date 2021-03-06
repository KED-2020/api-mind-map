# frozen_string_literal: true

require 'http'
require 'yaml'

####################################
## Configuration
####################################
GITHUB_TOKEN = YAML.safe_load(File.read('config/secrets.yml'))['test']['GITHUB_TOKEN']

gh_response = {}
gh_results = {}

####################################
## API
####################################
def format_api_path(path)
  "https://api.github.com/#{path}"
end

def call_github(url, params = {})
  HTTP
    .headers(
      'Accept' => 'application/vnd.github.mercy-preview+json',
      'Authorization' => "token #{GITHUB_TOKEN}"
    ).get(url, params: params)
end

def topics_to_query(topics)
  return '' if topics.length.zero?

  topics.reduce('') do |query, topic|
    "#{query} topic:#{topic}"
  end
end

####################################
## HAPPY Documents request
####################################

# Search & Find Repository
TOPICS = %w[tensorflow natural-language-processing].freeze
SEARCH_QUERY = "pytorch-transformers in:readme #{topics_to_query(TOPICS)}".freeze

search_repo_params = {
  q: SEARCH_QUERY,
  sort: 'starts',
  order: 'desc'
}

repo_search_url = format_api_path('search/repositories')
gh_response[repo_search_url] = call_github(repo_search_url, search_repo_params)

repo_search = gh_response[repo_search_url].parse

selected_document = repo_search['items'][0]

# Explore the selected repo
gh_results['name'] = selected_document['name']
# transformers

gh_results['html_url'] = selected_document['html_url']
# Should be https://github.com/huggingface/transformers

gh_results['description'] = selected_document['description']
# Should be \U0001F917Transformers: State-of-the-art Natural Language Processing for Pytorch and TensorFlow 2.0.

gh_results['topics'] = selected_document['topics']

####################################
## SAD documents request
####################################

# Bad Search Request

LONG_SEARCH_QUERY = 10.times.map { ('a'..'z').to_a }.join
invalid_query_url = format_api_path('search/repositories')

gh_response[invalid_query_url] = call_github(invalid_query_url, { q: LONG_SEARCH_QUERY })
# Should be The search is longer than 256 characters.

# Invalid API endpoint
invalid_endpoint_url = format_api_path('search/invalid')
gh_response[invalid_endpoint_url] = call_github(invalid_endpoint_url, search_repo_params)

####################################
## HAPPY Single Document Request
####################################
document_owner = 'derrxb'
document = 'derrxb'
document_path = document_owner + '/' + document

get_repo_url = format_api_path('repos/')
gh_response[get_repo_url] = call_github(get_repo_url + document_path)
document_response = gh_response[get_repo_url].parse

# Explore the returned repo
gh_results['document_id'] = document_response['id']
gh_results['document_name'] = document_response['name']
gh_results['document_html_url'] = document_response['html_url']
gh_results['document_description'] = document_response['description']
gh_results['document_topics'] = document_response['topics']

####################################
## Save Results
####################################
File.write('spec/fixtures/github_results.yml', gh_results.to_yaml)
