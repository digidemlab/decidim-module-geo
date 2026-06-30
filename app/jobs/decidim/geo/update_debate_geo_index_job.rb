# frozen_string_literal: true

module Decidim
  module Geo
    class UpdateDebateGeoIndexJob < ::ApplicationJob
      include Decidim::SanitizeHelper
      include Decidim::Geo::GeoIndexMethods
      queue_as :default

      alias debate resource
      alias debate= resource=

      def perform(decidim_geo_hash, resource)
        @decidim_geo_hash = decidim_geo_hash
        @resource = resource
        @resource_id = decidim_geo_hash[:resource_id]
        return remove_debate unless resource

        sync_debate
      end

      private

      def sync_debate
        return remove_debate if remove_from_index?

        upsert_index(upsert_index(@resource_id, manifest_name, with_organization(with_taxonomy(with_coords(@decidim_geo_hash)))))
        true
      rescue StandardError => e
        Rails.logger.debug { "Can index #{e}" }
        false
      end

      def remove_debate
        match = Decidim::Geo::Index.find_by(resource_id:, resource_type: manifest_name)
        match.destroy if match
      end

      def remove_from_index?
        !debate.visible?
      end

      def manifest_name
        "debates"
      end
    end
  end
end
