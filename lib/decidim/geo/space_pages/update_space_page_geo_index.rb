# frozen_string_literal: true

module Decidim
  module Geo
    module UpdateSpacePageGeoIndex
      extend ActiveSupport::Concern

      included do
        after_save :update_space_page_geo_index
        def update_space_page_geo_index
          return unless Decidim.const_defined?("SpacePage")

          # Call organization's update index
          organization.update_decidim_geo_index
        end
      end
    end
  end
end
