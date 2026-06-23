# frozen_string_literal: true

module Decidim
  module Geo
    module GeoIndexMethods
      include Decidim::Geo::GenericSerializer
      def upsert_index(resource_id, resource_type, decidim_geo_hash)
        decidim_geo_hash = with_no_index(decidim_geo_hash)
        lat = decidim_geo_hash.delete(:latitude)
        lon = decidim_geo_hash.delete(:longitude)

        decidim_geo_hash = with_machine_translations(decidim_geo_hash)

        index = Decidim::Geo::Index.find_or_initialize_by(resource_id:, resource_type:)

        index.assign_attributes(decidim_geo_hash)

        index.lonlat = if lat && lon && !lat.nan? && !lon.nan?
                         factory = Decidim::Geo.point_factory
                         factory.point(lon, lat)
                       end

        index.resource_id = resource_id
        index.resource_type = resource_type
        index.save!
      end

      def with_organization(decidim_geo_hash)
        decidim_geo_hash[:decidim_organization_id] = resource.organization.id if resource.respond_to?(:organization)
        decidim_geo_hash
      end

      def with_taxonomy(decidim_geo_hash)
        return decidim_geo_hash if taxonomy.first.nil?

        decidim_geo_hash[:geo_taxonomy_id] = taxonomy.first.id
        decidim_geo_hash
      end

      def with_coords(decidim_geo_hash)
        return decidim_geo_hash unless has_coordinates?

        decidim_geo_hash[:latitude] = latitude
        decidim_geo_hash[:longitude] = longitude
        decidim_geo_hash
      end

      def with_no_index(decidim_geo_hash)
        decidim_geo_hash[:avoid_index] = if resource.class.include? Decidim::HasComponent
                                           resource.component.decidim_geo_avoid_index?
                                         else
                                           false
                                         end
        decidim_geo_hash
      end

      def with_machine_translations(decidim_geo_hash)
        [:title, :short_description, :description_html].each do |attr|
          next unless decidim_geo_hash[attr].include?("machine_translations")

          key_with_mt = decidim_geo_hash[attr]
          mt = key_with_mt.delete("machine_translations")
          mt.each_key do |language|
            key_with_mt.update(mt.slice(language)) if !key_with_mt.has_key?(language) || key_with_mt[language]&.gsub(/<[^>]*>/, "")&.empty?
          end

          decidim_geo_hash[attr] = key_with_mt
        end

        decidim_geo_hash
      end

      def default_locale
        resource.organization.default_locale.to_s
      end

      private

      def has_coordinates?
        latitude && longitude
      end

      def decidim_geo_update_components!(space_klass)
        return unless resource.class.include? Decidim::ScopableParticipatorySpace

        decidim_geo_linked_components(space_klass).each(&:update_decidim_geo_index)
      end

      def decidim_geo_linked_components(space_klass)
        @decidim_geo_linked_components ||= begin
          registry = Decidim::Geo::ManifestRegistry.instance
          active_manifest_names = registry.active_manifests(&:keys)
          Decidim::Component.where(
            participatory_space_id: resource_id,
            participatory_space_type: space_klass.name,
            manifest_name: active_manifest_names
          )
        end
      end
    end
  end
end
