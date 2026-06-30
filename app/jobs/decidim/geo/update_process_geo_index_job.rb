# frozen_string_literal: true

module Decidim
  module Geo
    class UpdateProcessGeoIndexJob < ::ApplicationJob
      include Decidim::SanitizeHelper
      include Decidim::Geo::GeoIndexMethods
      queue_as :default

      alias process resource
      alias process= resource=

      def perform(decidim_geo_hash, resource)
        @decidim_geo_hash = decidim_geo_hash
        @resource = resource
        @resource_id = decidim_geo_hash[:resource_id]
        return remove_process unless resource

        sync_process
      end

      private

      def sync_process
        return remove_process if remove_from_index?

        upsert_index(@resource_id, manifest_name, with_organization(with_taxonomy(with_coords(@decidim_geo_hash))))
        true
      rescue StandardError => e
        Rails.logger.debug { "Can not index #{e}" }
        raise e
      end

      def remove_process
        match = Decidim::Geo::Index.find_by(resource_id:, resource_type: manifest_name)
        match.destroy if match
        decidim_geo_update_components!(Decidim::ParticipatoryProcess)
      end

      def remove_from_index?
        !process.visible?
      end

      def manifest_name
        "participatory_processes"
      end
    end
  end
end
