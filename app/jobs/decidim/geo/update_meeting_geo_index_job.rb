# frozen_string_literal: true

module Decidim
  module Geo
    class UpdateMeetingGeoIndexJob < ::ApplicationJob
      include Decidim::SanitizeHelper
      include Decidim::Geo::GeoIndexMethods
      queue_as :default

      alias meeting resource
      alias meeting= resource=

      def perform(meeting_id)
        @resource_id = meeting_id
        @resource = Decidim::Meetings::Meeting.where(id: meeting_id).first
        return remove_meeting unless resource

        sync_meeting
      end

      private

      def sync_meeting
        return remove_meeting if remove_from_index?

        upsert_index(meeting.id, manifest_name,
                     with_organization(
                       with_taxonomy(
                         with_coords(
                           resource_url:,
                           image_url:,
                           title:,
                           short_description:,
                           description_html: description,
                           start_date: meeting.start_time,
                           end_date: meeting.end_time,
                           component_id: meeting.decidim_component_id,
                           participatory_space_id: meeting.participatory_space.id,
                           participatory_space_type: meeting.participatory_space.manifest.name.to_s,
                           extended_data: {
                             default_locale:
                           }
                         )
                       )
                     ))
        true
      rescue StandardError => e
        Rails.logger.debug { "Can index #{e}" }
        false
      end

      def with_coords(decidim_geo_hash)
        return decidim_geo_hash unless meeting.type_of_meeting == "in_person"

        super
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
