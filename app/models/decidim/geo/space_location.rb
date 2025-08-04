# frozen_string_literal: true

module Decidim
  module Geo
    # Data fo the shapfiles uploaded
    class SpaceLocation < ApplicationRecord
      self.table_name = "decidim_geo_space_locations"
      belongs_to :decidim_geo_space, polymorphic: true

      def has_address?
        !latitude.nil? && !longitude.nil?
      end

      def organization
        decidim_geo_space.organization if decidim_geo_space.present?
      end
    end
  end
end
