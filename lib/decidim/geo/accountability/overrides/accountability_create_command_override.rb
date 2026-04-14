# frozen_string_literal: true

module Decidim
  module Geo
    module AccountabilityCreateCommandOverride
      extend ActiveSupport::Concern
      included do
        alias_method :decidim_original_run_after_hooks, :run_after_hooks

        private

        def run_after_hooks
          decidim_original_run_after_hooks
          result = @resource
          return result if !form.decidim_geo_has_address? && !form.geocoded?

          location = result.decidim_geo_space_location || Decidim::Geo::SpaceLocation.new
          location.address = form.decidim_geo_space_address
          location.latitude = form.latitude
          location.longitude = form.longitude
          result.decidim_geo_space_location = location
          result.save!
          result.reload
        end
      end
    end
  end
end
