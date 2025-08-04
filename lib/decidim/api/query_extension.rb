# frozen_string_literal: true

module Decidim
  module Geo
    # GeoQueryExtension
    module QueryExtension
      def self.included(type)
        type.field :geo_shapefiles, [Decidim::Geo::GeoShapefileType], description: "Return's information about the shapefiles", null: true do
          argument :title, [String], required: false
        end

        type.field :geo_shapedata, [Decidim::Geo::GeoShapedataType], description: "Return's datas from shapefile",
                                                                     null: true do
          argument :name, [String], required: false
        end

        type.field :geo_config, Decidim::Geo::GeoConfigType, description: "Return's information about the geo config",
                                                             null: true

        type.field :geo_scope, [Decidim::Geo::GeoScopeApiType], description: "Return's scopes with shapedatas",
                                                                null: true do
          argument :id, type: [Integer], required: false
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

      def geo_scope(id: [])
        scopes = Decidim::Scope.where(organization: current_organization).includes(:shapedata)
        return scopes.all if id.empty?

        scopes.where(id:)
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
