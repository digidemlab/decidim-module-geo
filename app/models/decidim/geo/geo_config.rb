# frozen_string_literal: true

module Decidim
  module Geo
    # The data store for geo configuration default.
    class GeoConfig < ApplicationRecord
      self.table_name = "decidim_geo_configs"
      enum :default_geoencoded_filter, { force_geoencoded: 0, no_force_geoencoded: 1 }
      validates :longitude, :latitude, :zoom, presence: true
      validates :decidim_organization_id, presence: true

      def self.geo_config_default(organization)
        Decidim::Geo::GeoConfig
          .find_or_create_by(decidim_organization_id: organization.id) do |geo_config|
            geo_config.latitude = 0
            geo_config.longitude = 0
            geo_config.zoom = 13
            geo_config.decidim_organization_id = organization.id
            geo_config.tile = tile_layer_default
            geo_config.maptiler_api_key = ""
            geo_config.maptiler_style_id = ""
            geo_config.default_geoencoded_filter = 1
            geo_config
        end
      end

      def self.tile_layer_default
        return "" if Decidim.config.maps.blank?

        Decidim.config.maps.dig(:dynamic, :tile_layer, :url) || ""
      end
    end
  end
end
