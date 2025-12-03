# frozen_string_literal: true

module Decidim
  module Geo
    class UpdateDebateGeoIndexJob < ::ApplicationJob
      include Decidim::SanitizeHelper
      include Decidim::Geo::GeoIndexMethods
      queue_as :default

      alias debate resource
      alias debate= resource=

      def perform(debate_id)
        @resource_id = debate_id
        @resource = Decidim::Debates::Debate.where(id: debate_id).first
        return remove_debate unless resource

        sync_debate
      end

      private

      def sync_debate
        return remove_debate if remove_from_index?

        upsert_index(debate.id, manifest_name,
                     with_organization(
                       with_scope(
                         with_coords(
                           resource_url:,
                           image_url:,
                           title:,
                           short_description:,
                           description_html: description,
                           end_date:,
                           component_id: debate.decidim_component_id,
                           participatory_space_id: debate.participatory_space.id,
                           participatory_space_type: debate.participatory_space.manifest.name.to_s,
                           extended_data: {
                             start_time: debate.start_time,
                             end_time: debate.end_time,
                             component_url:,
                             space_page_host:
                           }
                         )
                       )
                     ))
        true
      rescue StandardError => e
        Rails.logger.debug { "Can index #{e}" }
        false
      end

      def component_url
        return unless resource.organization.space_page?

        "https://#{resource.organization.host}#{resource_url}"
      end

      def space_page_host
        resource.organization.host
      end

      def end_date
        resource.closed_at.to_date if resource.closed_at
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
