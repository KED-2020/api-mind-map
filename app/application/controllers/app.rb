# frozen_string_literal: true

require 'roda'
require 'delegate'

module MindMap
  # Environment-specific configuration
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows DELETE and other HTTP verbs beyond GET/POST
    plugin :caching

    use Rack::MethodOverride # for other HTTP verbs (with plugin all_verbs)

    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message = "MindMap API v1 at /api/v1/ in #{App.environment} mode"

        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message: message)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do
        # Inboxes
        routing.on 'inboxes' do
          routing.is do
            # POST api/v1/inboxes
            routing.post do
              params = Request::AddInbox.new(routing.params)

              result = Service::AddInbox.new.call(params: params)

              Representer::For.new(result).status_and_body(response)
            end
          end

          # GET api/v1/inboxes/mnemonics
          routing.on 'mnemonics' do
            routing.get do
              result = Service::GetNewInboxUrl.new.call

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              result.value!.message
            end
          end

          # GET api/v1/inboxes/:inbox_url
          routing.on String do |inbox_url|
            # GET api/v1/inboxes/:inbox_url/documents
            routing.on 'documents' do
              routing.get do
                result = Service::GetInboxDocuments.new.call(inbox_url: inbox_url)

                Representer::For.new(result).status_and_body(response)
              end
            end

            routing.on 'suggestions' do
              routing.on String do |suggestion_id|
                # POST api/v1/inboxes/:inbox_url/suggestions/:suggestion_id
                routing.post do
                  result = Service::SaveInboxSuggestion.new.call(suggestion_id: suggestion_id, inbox_url: inbox_url)

                  Representer::For.new(result).status_and_body(response)
                end

                # DELETE api/v1/inboxes/:inbox_url/suggestions/:suggestion_id
                routing.delete do
                  result = Service::DeleteInboxSuggestion.new.call(suggestion_id: suggestion_id, inbox_url: inbox_url)

                  Representer::For.new(result).status_and_body(response)
                end
              end
            end

            routing.on 'subscriptions' do
              # GET api/v1/inboxes/:inbox_url/subscriptions
              routing.get do
                result = Service::GetInboxSubscriptions.new.call(inbox_url: inbox_url)

                Representer::For.new(result).status_and_body(response)
              end

              # POST api/v1/inboxes/:inbox_url/subscriptions
              routing.post do
                params = Request::AddSubscription.new(routing.params.merge!('inbox_url' => inbox_url))

                result = Service::AddSubscription.new.call(params: params)

                Representer::For.new(result).status_and_body(response)
              end

              routing.on String do |subscription_id|
                # DELETE api/v1/inboxes/:inbox_url/subscriptions/:subscription_id
                routing.delete do
                  result = Service::DeleteInboxSubscription.new.call(inbox_url: inbox_url,
                                                                     subscription_id: subscription_id)

                  Representer::For.new(result).status_and_body(response)
                end
              end
            end

            # GET api/v1/inboxes/:inbox_url
            routing.get do
              inbox_find = Request::EncodedInboxId.new(inbox_url)

              result = Service::GetInbox.new.call(inbox_url: inbox_find)

              Representer::For.new(result).status_and_body(response)
            end
          end
        end

        # Documents
        routing.on 'documents' do
          # POST api/v1/documents
          routing.post do
            html_url = Request::AddDocument.new(routing.params)

            result = Service::AddDocument.new.call(html_url: html_url)

            Representer::For.new(result).status_and_body(response)
          end

          # GET api/v1/documents/:document_id
          routing.on String do |document_id|
            routing.get do
              response.cache_control public: true, max_age: 3600

              result = MindMap::Service::GetDocument.new.call(document_id: document_id)

              Representer::For.new(result).status_and_body(response)
            end
          end
        end
      end
    end
  end
end
