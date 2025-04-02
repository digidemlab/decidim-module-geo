# frozen_string_literal: true

module Decidim
  module Geo
    module CreateComponentCommandOverride
      extend ActiveSupport::Concern
      included do
        alias_method :decidim_original_run_after_hooks, :run_after_hooks

        private

        def run_after_hooks
          decidim_original_run_after_hooks
          avoid_index_relation = resource.decidim_geo_avoid_index || Decidim::Geo::NoIndex.new
          avoid_index_relation.decidim_component_id = resource.id
          avoid_index_relation.no_index = form.decidim_geo_avoid_index
          resource.decidim_geo_avoid_index = avoid_index_relation
          resource.save
          resource.reload
        end
      end
    end
  end
end
