# frozen_string_literal: true

module Decidim
  module Geo
    module GeoSpaceAddressForm
      # This module is designed to integrate address forms into components and spaces.
      extend ActiveSupport::Concern
      included do
        alias_method :decidim_original_map_model, :map_model
        attribute :latitude, ActiveModel::Type::Float
        attribute :longitude, ActiveModel::Type::Float

        attribute :decidim_geo_space_address, ActiveModel::Type::String
        validates :decidim_geo_space_address, geocoding: true, if: ->(form) { form.decidim_geo_has_address? && !form.geocoded? }
        validates :decidim_geo_space_address, presence: true, if: :coords_with_address?

        def map_model(model)
          decidim_original_map_model(model)
          location = model.decidim_geo_space_location || Decidim::Geo::SpaceLocation.new
          self.decidim_geo_space_address = location.address
          self.latitude = location.latitude
          self.longitude = location.longitude
        end

        def geocoding_enabled?
          Decidim::Map.available?(:geocoding)
        end

        def geocoded?
          latitude.present? && longitude.present?
        end

        def decidim_geo_has_address?
          decidim_geo_space_address.present?
        end

        def coords_with_address?
          !decidim_geo_has_address? && geocoded?
        end

        def organization
          context[:current_organization]
        end
      end
    end
  end
end
