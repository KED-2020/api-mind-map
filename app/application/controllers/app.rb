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

    # rubocop:disable Metrics/BlockLength
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
            routing.post do
              params = Request::AddInbox.new(routing.params)

              result = Service::AddInbox.new.call(params: params)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              # Return the inbox the uses just created
              Representer::Inbox.new(result.value!.message).to_json
            end
          end

          # GET /inboxes/mnemonics
          routing.on 'mnemonics' do
            routing.get do
              result = Service::GetNewInboxId.new.call

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              result.value!.message
            end
          end

          # GET /inboxes/{inbox_id}
          routing.on String do |inbox_id|
            routing.on 'documents' do
              routing.get do
                result = Service::GetInboxDocuments.new.call(inbox_id: inbox_id)

                if result.failure?
                  failed = Representer::HttpResponse.new(result.failure)
                  routing.halt failed.http_status_code, failed.to_json
                end

                http_response = Representer::HttpResponse.new(result.value!)
                response.status = http_response.http_status_code

                Representer::DocumentsList.new(
                  result.value!.message
                ).to_json
              end
            end

            routing.on 'suggestions' do
              routing.on String do |suggestion_id|
                routing.post do
                  result = Service::SaveInboxSuggestion.new.call(suggestion_id: suggestion_id, inbox_id: inbox_id)

                  if result.failure?
                    failed = Representer::HttpResponse.new(result.failure)
                    routing.halt failed.http_status_code, failed.to_json
                  end

                  http_response = Representer::HttpResponse.new(result.value!)
                  response.status = http_response.http_status_code

                  Representer::Document.new(
                    result.value!.message
                  ).to_json
                end

                routing.delete do
                  result = Service::DeleteInboxSuggestion.new.call(suggestion_id: suggestion_id, inbox_id: inbox_id)

                  if result.failure?
                    failed = Representer::HttpResponse.new(result.failure)
                    routing.halt failed.http_status_code, failed.to_json
                  end

                  http_response = Representer::HttpResponse.new(result.value!)
                  response.status = http_response.http_status_code

                  result.value!.message
                end
              end
            end

            routing.on 'subscriptions' do
              routing.get do
                # All the subscriptions for an inbox
              end

              routing.post do
                puts 'hi'
                # Add a subscription to an inbox
              end

              routing.delete do
                # Delete a subscription for an inbox
              end
            end

            routing.get do
              inbox_find = Request::EncodedInboxId.new(inbox_id)

              result = Service::GetInbox.new.call(inbox_id: inbox_find)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::Inbox.new(
                result.value!.message
              ).to_json
            end
          end
        end

        # Documents
        routing.on 'documents' do
          # POST /documents
          routing.post do
            html_url = Request::AddDocument.new(routing.params)

            result = Service::AddDocument.new.call(html_url: html_url)

            if result.failure?
              failed = Representer::HttpResponse.new(result.failure)
              routing.halt failed.http_status_code, failed.to_json
            end

            http_response = Representer::HttpResponse.new(result.value!)
            response.status = http_response.http_status_code

            # Return the document the user just created
            Representer::Document.new(
              result.value!.message
            ).to_json
          end

          # GET /documents/{document_id}
          routing.on String do |document_id|
            routing.get do
              response.cache_control public: true, max_age: 3600

              result = MindMap::Service::GetDocument.new.call(document_id: document_id)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              # Return the document the user requested
              Representer::Document.new(
                result.value!.message
              ).to_json
            end
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
