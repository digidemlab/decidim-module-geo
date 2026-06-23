# frozen_string_literal: true

module Decidim
  module Geo
    # This type represents a Decidim's global property.
    class GeoCoordinatesType < Decidim::Api::Types::BaseObject
      description "Physical coordinates for a location"

      field :latitude, GraphQL::Types::Float, null: true, description: "Latitude of this coordinate."
      field :longitude, GraphQL::Types::Float, null: true, description: "Longitude of this coordinate."
    end
  end
end
