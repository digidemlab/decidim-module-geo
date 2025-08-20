# frozen_string_literal: true

module Decidim
  module Geo
    module Admin
      # A form object to be used when admin configure default .
      class GeoConfigForm < Form
        attribute :longitude, Float
        attribute :latitude, Float
        attribute :zoom, Integer
        attribute :tile, String
        attribute :maptiler_api_key, String
        attribute :maptiler_style_id, String
        attribute :only_assemblies, Boolean
        attribute :only_processes, Boolean
        attribute :default_geoencoded_filter, String
        attribute :focus_zoom_level, Integer

        alias organization current_organization
        validate :zoom_is_valid

        def zoom_is_valid
          errors.add(:zoom, :invalid_range) if zoom.present? && (zoom < 5 || zoom > 19)
          errors.add(:focus_zoom_level, :invalid_range) if focus_zoom_level.present? && (focus_zoom_level < 5 || zoom > 19)
        end
      end
    end
  end
end
