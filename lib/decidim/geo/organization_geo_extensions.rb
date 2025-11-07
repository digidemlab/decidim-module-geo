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

        def geo_enabled?
          return true unless Decidim.const_defined?("SpacePage")
          return true if current_organization.space_page_generator?

          decidim_geo_space_enabled?
        end

        def decidim_geo_space_enabled?
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
      end
    end
  end
end
