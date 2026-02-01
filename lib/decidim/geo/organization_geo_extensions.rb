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

        delegate :geo_mode, to: :geo_settings, allow_nil: true

        after_create :set_default_geo_mode

        def geo_enabled?
          current_organization.geo_mode.present? && current_organization.geo_mode != "disabled"
        end

        def current_organization
          self
        end

        def geo_mode=(value)
          build_geo_settings if geo_settings.nil?
          geo_settings.geo_mode = value
          geo_settings.save
        end

        def set_default_geo_mode
          return if geo_settings.present?

          build_geo_settings(geo_mode: "enabled_empty")
          geo_settings.save
        end
      end
    end
  end
end
