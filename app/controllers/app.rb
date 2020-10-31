# frozen_string_literal: true

require 'roda'
require 'slim'

module MindMap
  # Web app
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :halt

    route do |routing|
      routing.assets # Load CSS

      # GET /
      routing.root do
        view 'home'
      end

      # Resource
      routing.on 'resource' do
        routing.is do
          routing.get do
            search_term = routing.params['search']
            tags_term = routing.params['tags']

            routing.halt 400 unless search_term.length.positive?

            tags = tags_term&.length&.positive? ? tags_term.split(',') : []

            resource = Github::ResourceMapper
                       .new(GH_TOKEN)
                       .search(search_term, tags)

            routing.halt 404 unless resource

            view 'resource', locals: { resource: resource }
          end

          routing.post do
            search_term = routing.params['search'].downcase
            tags_term = routing.params['tags']

            routing.halt 400 unless search_term.length.positive?

            routing.redirect "resource?search=#{search_term}&tags=#{tags_term}"
          end
        end
      end
    end
  end
end
