# frozen_string_literal: true

module Decidim
  module Geo
    class UpdateAccountabilityGeoIndexJob < ::ApplicationJob
      include Decidim::SanitizeHelper
      include Decidim::Geo::GeoIndexMethods
      queue_as :default

      alias accountability_result resource
      alias accountability_result= resource=

      def perform(decidim_geo_hash, resource)
        @decidim_geo_hash = decidim_geo_hash
        @resource = resource
        @resource_id = decidim_geo_hash[:resource_id]
        return remove_accountability_result unless resource

        sync_accountability_result
      end

      private

      def sync_accountability_result
        return remove_accountability_result if remove_from_index?

        upsert_index(@resource_id, manifest_name, with_organization(with_taxonomy(with_coords(@decidim_geo_hash))))
        true
      rescue StandardError => e
        Rails.logger.debug { "Can't index #{e}" }
        false
      end

      def remove_accountability_result
        match = Decidim::Geo::Index.find_by(resource_id:, resource_type: manifest_name)
        match.destroy if match
      end

      def remove_from_index?
        !accountability_result.visible?
      end

      def manifest_name
        "accountability"
      end
    end
  end
end
