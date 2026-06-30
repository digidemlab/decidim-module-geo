# frozen_string_literal: true

module Decidim
  module Geo
    class UpdateAssemblyGeoIndexJob < ::ApplicationJob
      include Decidim::SanitizeHelper
      include Decidim::Geo::GeoIndexMethods
      queue_as :default

      alias assembly resource
      alias assembly= resource=

      def perform(decidim_geo_hash, resource)
        @decidim_geo_hash = decidim_geo_hash
        @resource = resource
        @resource_id = decidim_geo_hash[:resource_id]
        return remove_assembly unless resource

        sync_assembly
      end

      private

      def sync_assembly
        return remove_assembly if remove_from_index?

        upsert_index(upsert_index(@resource_id, manifest_name, with_organization(with_taxonomy(with_coords(@decidim_geo_hash)))))
        true
      rescue StandardError => e
        Rails.logger.debug { "Error: can not geo-index this assembly: #{e}" }
        false
      end

      def remove_assembly
        match = Decidim::Geo::Index.find_by(resource_id:, resource_type: manifest_name)
        match.destroy if match
        decidim_geo_update_components!(Decidim::Assembly)
      end

      def remove_from_index?
        !assembly.visible? || !Decidim::Assembly.visible_for(nil).find(assembly.id)
      end

      def manifest_name
        "assemblies"
      end
    end
  end
end
