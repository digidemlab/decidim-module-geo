# frozen_string_literal: true

module Decidim
  module Geo
    class AutomaticTaxonomyJob < ::ApplicationJob
      include Decidim::Geo::GeoIndexMethods
      queue_as :default

      def perform
        # Select all the components where space's taxonomy is nil
        # and get the component Ids.
        # loop over all the resources that have no taxonomy
        transaction do
          registry.registered_manifests.each do |manifest|
            model = registry.model_for(manifest)
            model_resources(model)
          end
        end
      end

      private

      def model_resources(model)
        model.all.each do |resource|
          space = resource.class.respond_to?(:participatory_space?) ? resource : resource.participatory_space

          space_without_taxonomy(space)
        end
      end

      def space_without_taxonomy(space)
        assign_taxonomy(space) unless space.taxonomies.map { |t| t.shapedata.present? }.include?(true)
      end

      def assign_taxonomy(space)
        taxonomy = taxonomy_shapedata(space)
        space.taxonomies << taxonomy if taxonomy
        space.save!
      end

      def taxonomy_shapedata(space)
        lat = latitude(space)
        lon = longitude(space)
        return unless lat && lon

        shape = Decidim::Geo::Shapedata.where("ST_Contains(geom, ST_SetSRID(ST_MakePoint(?, ?), 4326))", lon, lat).first
        return unless shape

        Decidim::Taxonomy.where(shapedata: shape).first
      end

      def spaces
        @spaces ||= registry.active_manifests do |registry|
          registry.select do |_manifest_name, options|
            model = options[:model]
            model.to_s.constantize.respond_to?(:participatory_space?)
          end
        end
      end

      def components_without_taxonomy
        @components_without_taxonomy ||= spaces.map do |_manifest_name, space_options|
          space_options[:model].where.missing(:taxonomies).select(:id).map do |space|
            Decidim::Component.where(
              participatory_space_type: space_options[:model].name,
              participatory_space_id: space.id,
              manifest_name: component_manifests
            ).to_a
          end.flatten
        end.flatten
      end

      def component_manifests
        @component_manifests ||= component_options.keys
      end

      def component_options
        @component_options ||= registry.active_manifests do |registry|
          registry.select do |_manifest_name, options|
            model = options[:model]
            model.include?(Decidim::HasComponent)
          end
        end
      end

      def latitude(resource)
        if location_overriden?(resource)
          location(resource).latitude if location(resource) && location(resource).latitude
        elsif resource.respond_to?(:latitude)
          resource.latitude
        end
      end

      def longitude(resource)
        if location_overriden?(resource)
          location(resource).longitude if location(resource) && location(resource).longitude
        elsif resource.respond_to?(:longitude)
          resource.longitude
        end
      end

      def location(resource)
        resource.decidim_geo_space_location
      end

      def location_overriden?(resource)
        resource.respond_to?(:decidim_geo_space_location)
      end

      def registry
        @registry ||= Decidim::Geo::ManifestRegistry.instance
      end
    end
  end
end
