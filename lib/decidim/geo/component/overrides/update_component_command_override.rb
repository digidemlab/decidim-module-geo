# frozen_string_literal: true

module Decidim
  module Geo
    module UpdateComponentCommandOverride
      extend ActiveSupport::Concern
      included do
        alias_method :decidim_original_update_component, :update_component

        private

        def update_component
          decidim_original_update_component

          avoid_index_relation = @component.decidim_geo_avoid_index || Decidim::Geo::NoIndex.new
          avoid_index_relation.decidim_organization_id = @component.organization.id
          avoid_index_relation.decidim_component_id = @component.id
          avoid_index_relation.no_index = form.decidim_geo_avoid_index
          @component.decidim_geo_avoid_index = avoid_index_relation
          @component.save!
          # Update geo index linked resources
          Decidim::Geo::Index.where(
            component_id: @component.id,
            resource_type: @component.manifest_name
          ).update(avoid_index: avoid_index_relation.no_index)

          hide_map_component = @component.decidim_geo_hide_map || Decidim::Geo::HideMap.new
          hide_map_component.decidim_organization_id = @component.organization.id
          hide_map_component.decidim_component_id = @component.id
          hide_map_component.hide_map = form.decidim_geo_hide_map

          @component.decidim_geo_hide_map = hide_map_component
          @component.save!
        end
      end
    end
  end
end
