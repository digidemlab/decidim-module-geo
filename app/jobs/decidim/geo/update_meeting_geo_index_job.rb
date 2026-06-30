# frozen_string_literal: true

module Decidim
  module Geo
    class UpdateMeetingGeoIndexJob < ::ApplicationJob
      include Decidim::SanitizeHelper
      include Decidim::Geo::GeoIndexMethods
      queue_as :default

      alias meeting resource
      alias meeting= resource=

      def perform(decidim_geo_hash, resource)
        @decidim_geo_hash = decidim_geo_hash
        @resource = resource
        @resource_id = decidim_geo_hash[:resource_id]
        return remove_meeting unless resource

        sync_meeting
      end

      private

      def sync_meeting
        return remove_meeting if remove_from_index?

        transaction do
          upsert_index(@resource_id, manifest_name, with_organization(with_taxonomy(with_coords(@decidim_geo_hash))))
          true
        end
      rescue StandardError => e
        Rails.logger.debug { "Can index #{e}" }
        false
      end

      def remove_meeting
        match = Decidim::Geo::Index.find_by(resource_id:, resource_type: manifest_name)
        match.destroy if match
      end

      def remove_from_index?
        !meeting.visible? || !meeting.published?
      end

      def manifest_name
        "meetings"
      end
    end
  end
end
