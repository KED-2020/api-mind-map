# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

module MindMap
  # Web app
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :halt
    plugin :partials

    # rubocop:disable Metrics/BlockLength
    route do |routing|
      routing.assets # Load CSS

      # GET /
      routing.root do
        view 'home'
      end

      routing.on '404' do
        routing.get do
          view '404'
        end
      end

      routing.on 'resource_nil' do
        view 'resource_nil'
      end

      # Inbox
      routing.on 'inbox' do
        routing.on 'new' do
          view 'new_inbox'
        end

        routing.post do
          inbox_id = routing.params['inbox_id']

          # Redirect to the get request
          routing.redirect "inbox/#{inbox_id}"
        end

        routing.on String do |inbox_id|
          routing.get do
            # Find the inbox specified by the url.
            inbox = Repository::Inbox::For.klass(Entity::Inbox)
                                          .find_url(inbox_id)

            routing.redirect '404' unless inbox

            # Load the suggestions for an inbox.
            suggestions = Mapper::Inbox.new(App.config.GITHUB_TOKEN).suggestions

            # Show the user their inbox
            view 'inbox', locals: { inbox: inbox, suggestions: suggestions }
          end
        end
      end

      # Resource
      routing.on 'resource' do
        routing.is do
          routing.post do
            search_term = routing.params['search']
            tags_term = routing.params['tags']

            routing.halt 400 unless search_term.length.positive?

            tags = tags_term&.length&.positive? ? tags_term.split(',') : []

            # Get the resource from Github
            resource = Github::ResourceMapper
                       .new(MindMap::App.config.GITHUB_TOKEN)
                       .search(search_term, tags)
            routing.redirect 'resource_nil' unless resource
            # Add the repo to database
            saved_resource = Repository::For.entity(resource).find_or_create(resource)

            # Redirect viewer to resource details
            routing.redirect "resource?resource_origin_id=#{saved_resource.origin_id}"
          end

          routing.get do
            resource_origin_id = routing.params['resource_origin_id']

            resource = Repository::For.klass(Entity::Resource)
                                      .find_origin_id(resource_origin_id)

            view 'resource', locals: { resource: resource }
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
