# frozen_string_literal: true

module Decidim
  module Geo
    module ParticipatoryProcessCommandOverride
      extend ActiveSupport::Concern
      included do
        alias_method :decidim_original_run_after_hooks, :run_after_hooks

        def run_after_hooks
          location = resource.decidim_geo_space_location || Decidim::Geo::SpaceLocation.new(
            decidim_geo_space_type: resource.class.name,
            decidim_geo_space_id: resource.id
          )
          location.address = form.decidim_geo_space_address
          location.latitude = form.latitude
          location.longitude = form.longitude
          location.save!
          resource.update!(decidim_geo_space_location: location)
          decidim_original_run_after_hooks
        end
      end
    end
  end
end
