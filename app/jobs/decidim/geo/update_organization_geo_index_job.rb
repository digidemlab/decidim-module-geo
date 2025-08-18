# frozen_string_literal: true

module Decidim
  module Geo
    class UpdateOrganizationGeoIndexJob < ::ApplicationJob
      include Decidim::SanitizeHelper
      include Decidim::Geo::GeoIndexMethods
      queue_as :default

      alias organization resource
      alias organization= resource=

      def perform(organization_id)
        @resource_id = organization_id
        @resource = Decidim::Organization.where(id: organization_id).first
        return remove_organization unless resource && resource.space_page?

        sync_organization
      end

      private

      def sync_organization
        return remove_organization if remove_from_index?

        # To index the generator organization, we will take its space page
        # details (run a serializer over the space page)
        space = organization.space_page
        serializer = UpdateSpacePageGeoIndexSerializer.new(space)
        generator_id = organization.space_page_settings_attributes["created_by_org"].to_i
        # Decidim::Geo::Index with resource_types = "space_pages", and details of the
        # space page (eg. Assembly, Participatory Process, etc.)
        # This will be saved under generator org index, to display it on generator side
        # and not on space page
        upsert_index(organization.id, manifest_name,
                     with_scope(
                       decidim_organization_id: generator_id,
                       latitude: serializer.latitude,
                       longitude: serializer.longitude,
                       resource_url: "https://#{organization.host}",
                       image_url: serializer.image_url,
                       title: serializer.title,
                       short_description: serializer.short_description,
                       description_html: serializer.description,
                       start_date: nil,
                       end_date: nil,
                       component_id: serializer.component_id,
                       participatory_space_id: serializer.participatory_space_id,
                       participatory_space_type: serializer.participatory_space_type
                     ))
      rescue StandardError => e
        Rails.logger.debug { "Can't index #{e}" }
        false
      end

      def remove_organization
        match = Decidim::Geo::Index.find_by(resource_id:, resource_type: manifest_name)
        match.destroy if match
      end

      def remove_from_index?
        false
      end

      def manifest_name
        "space_pages"
      end
    end
  end
end
