# frozen_string_literal: true

module Decidim
  module Geo
    # Class to copy settings from one organization to a new organization.
    # Used with the Space Page module, where the organization generator
    # copies its settings to the new single page.
    class DupGeneratorSettings
      def initialize(gen_organization, new_organization)
        @gen_org = gen_organization
        @new_org = new_organization
      end

      def execute_dup
        dup_geo_config
        dup_geo_settings
        dup_shapefile
      end

      def dup_geo_config
        Decidim::Geo::GeoConfig.where(decidim_organization_id: @gen_org.id).find_each do |geo_config|
          new_geo_config = geo_config.dup
          new_geo_config.decidim_organization_id = @new_org.id
          new_geo_config.save!
        end
      end

      def dup_geo_settings
        Decidim::Geo::GeoSettings.where(decidim_organization_id: @gen_org.id).find_each do |geo_settings|
          new_geo_settings = geo_settings.dup
          new_geo_settings.decidim_organization_id = @new_org.id
          new_geo_settings.save!
        end
      end

      def dup_shapefile
        Decidim::Geo::Shapefile.where(decidim_organization_id: @gen_org.id).find_each do |shapefile|
          new_shapefile = shapefile.dup
          new_shapefile.decidim_organization_id = @new_org.id
          new_shapefile.save!
          new_scope_type = dup_scope_type(shapefile, new_shapefile)
          dup_shapedata(new_scope_type, shapefile, new_shapefile)
        end
      end

      def dup_shapedata(new_scope_type, shapefile, new_shapefile)
        Decidim::Geo::Shapedata.where(decidim_geo_shapefiles_id: shapefile.id).find_each do |shapedata|
          new_shapedata = shapedata.dup
          new_shapedata.decidim_geo_shapefiles_id = new_shapefile.id
          new_shapedata.save!

          dup_scope(new_scope_type, shapedata, new_shapedata)
        end
      end

      def dup_scope_type(shapefile, new_shapefile)
        return unless shapefile.respond_to?(:decidim_scope_types_id) && shapefile.decidim_scope_types_id

        scope_type = Decidim::ScopeType.find(shapefile.decidim_scope_types_id)
        new_scope_type = scope_type.dup
        new_scope_type.shapefile = new_shapefile
        new_scope_type.decidim_organization_id = @new_org.id
        new_scope_type.save!

        new_scope_type
      end

      def dup_scope(new_scope_type, shapedata, new_shapedata)
        return unless shapedata.respond_to?(:decidim_scopes_id) && shapedata.decidim_scopes_id

        scope = Decidim::Scope.find(shapedata.decidim_scopes_id)
        new_scope = scope.dup
        new_scope.shapedata = new_shapedata
        new_scope.scope_type_id = new_scope_type.id
        new_scope.decidim_organization_id = @new_org.id
        new_scope.code = "#{scope.code}_#{@new_org.id}"
        new_scope.save!
      end
    end
  end
end
