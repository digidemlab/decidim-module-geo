# frozen_string_literal: true

module Decidim
  module Geo
    # GeoQueryExtension
    module QueryExtension
      def self.included(type)
        type.field :geo_shapefiles, [Decidim::Geo::GeoShapefileType], null: true, description: "Returns a list of geographic shapefiles, optionally filtered by title." do
          argument :title, [String], required: false, description: "Filters the shapefiles by matching titles."
        end

        type.field :geo_shapedata, [Decidim::Geo::GeoShapedataType], null: true,
                                                                     description: "Returns data records associated with a specific shapefile, optionally filtered by name." do
          argument :name, [String], required: false, description: "Filters the records by matching names."
        end

        type.field :geo_config, Decidim::Geo::GeoConfigType, description: "Return's information about the geo config",
                                                             null: true

        type.field :geo_taxonomy, [Decidim::Geo::GeoTaxonomyApiType], null: true,
                                                                      description: "Returns a list of geographic taxonomies, optionally including their associated shape data." do
          argument :id, [Integer], required: false, description: "Filters the taxonomies by their unique IDs."
        end
      end

      def geo_shapefiles(title: nil)
        return Decidim::Geo::Shapefile.where(title:) if title.present?

        all_shapefiles = Decidim::Geo::Shapefile.all
        Rails.cache.fetch("decidim_geo/#{all_shapefiles.cache_key_with_version}") do
          all_shapefiles
        end
      end

      def geo_shapedata(name: nil)
        collection = Decidim::Geo::Shapedata.where(decidim_organization_id: current_organization.id)
        return collection.where("data->>'NAME' in (?)", name) if name.present?

        collection
      end

      def geo_config
        @geo_config ||= Decidim::Geo::GeoConfig.geo_config_default(current_organization)
      end

      def geo_taxonomy(id: [])
        taxonomies = Decidim::Taxonomy.where(organization: current_organization).includes(:shapedata)
        return taxonomies.all if id.empty?

        taxonomies.where(id:)
      end

      private

      def current_user
        context[:current_user]
      end

      def current_organization
        context[:current_organization]
      end
    end
  end
end
