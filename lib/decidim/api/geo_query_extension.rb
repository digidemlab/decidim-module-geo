# frozen_string_literal: true

module Decidim
  module Geo
    module GeoQueryExtension
      # Public: Extends a type with `decidim_geo`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      def self.included(type)
        type.field :shapefiles, [Decidim::Geo::ShapefileType],
                   description: "Return's information about the shapefiles", null: true

        type.field :geo_config, Decidim::Geo::GeoConfigType, description: "Return's information about the geo config",
                                                             null: true
      end

      def shapefiles
        return [] if organization.blank?

        Decidim::Geo::Shapefile.where(decidim_organization_id: organization.id)
      end

      def geo_config
        @geo_config ||= Decidim::Geo::GeoConfig.geo_config_default(organization)
      end

      def organization
        @organization ||= context.organization
      end
    end
  end
end
