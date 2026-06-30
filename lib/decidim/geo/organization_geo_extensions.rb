# frozen_string_literal: true

module Decidim
  module Geo
    module OrganizationGeoExtensions
      extend ActiveSupport::Concern

      included do
        def geo_features_toggle
          @geo_features_toggle ||= Decidim::Toggle.config_for(self, Decidim::Geo::MODULE_NAME)
        end

        def geo_enabled?
          return false unless geo_features_toggle

          !!geo_features_toggle[:enabled]
        end

        def geo_search_enabled?
          geo_enabled? && !!geo_features_toggle[:search_bar]
        end
      end
    end
  end
end
