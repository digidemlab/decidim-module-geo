# frozen_string_literal: true

module Decidim
  module Geo
    module OrganizationGeoExtensions
      extend ActiveSupport::Concern

      included do
        has_one :geo_settings,
                class_name: "Decidim::Geo::GeoSettings",
                foreign_key: :decidim_organization_id,
                autosave: true,
                dependent: :destroy

        delegate :geo_enabled, to: :geo_settings, allow_nil: true

        def geo_enabled?
          geo_enabled.nil? ? true : geo_enabled
        end

        def geo_enabled=(value)
          build_geo_settings if geo_settings.nil?
          geo_settings.geo_enabled = value
          geo_settings.save
        end
      end
    end
  end
end
