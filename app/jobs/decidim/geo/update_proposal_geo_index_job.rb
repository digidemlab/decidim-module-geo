# frozen_string_literal: true

module Decidim
  module Geo
    class UpdateProposalGeoIndexJob < ::ApplicationJob
      include Decidim::SanitizeHelper
      include Decidim::Geo::GeoIndexMethods
      queue_as :default

      alias proposal resource
      alias proposal= resource=

      def perform(decidim_geo_hash, resource)
        @decidim_geo_hash = decidim_geo_hash
        @resource = resource
        @resource_id = decidim_geo_hash[:resource_id]
        return remove_proposal unless resource

        sync_proposal
      end

      private

      def sync_proposal
        return remove_proposal if remove_from_index?

        upsert_index(@resource_id, manifest_name, with_organization(with_taxonomy(with_coords(@decidim_geo_hash))))
        true
      rescue StandardError => e
        Rails.logger.warn { "ERROR:  #{e}" }
        false
      end

      def remove_proposal
        match = Decidim::Geo::Index.find_by(resource_id:, resource_type: manifest_name)
        match.destroy if match
      end

      def remove_from_index?
        !proposal.visible?
      end

      def manifest_name
        "proposals"
      end
    end
  end
end
