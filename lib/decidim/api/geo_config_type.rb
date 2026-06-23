# frozen_string_literal: true

module Decidim
  module Geo
    class GeoConfigType < Decidim::Api::Types::BaseObject
      description "A geo admin config"

      field :latitude, Float, null: false, description: "The geographic latitude coordinate in degrees."
      field :longitude, Float, null: false, description: "The geographic longitude coordinate in degrees."
      field :tile, String, null: true, description: "The URL template for the map tile server."
      field :zoom, Float, null: false, description: "The default zoom level for the map view."
    end
  end
end
