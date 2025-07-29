# frozen_string_literal: true

module Decidim
  module Geo
    ##
    # Inserted in registered participatory spaces (eg. Assembly, Participatory Process, etc.)
    # Will trigger the main organization geo update
    module UpdateSpacePageGeoIndex
      extend ActiveSupport::Concern

      included do
        after_save :update_space_page_geo_index
        def update_space_page_geo_index
          # If module is not installed, skip
          return unless Decidim.const_defined?("SpacePage")
          # If organization is a generator, it might have many assemblies, do nothing. 
          return unless organization.space_page_generator?
          # Call organization's update index
          organization.update_decidim_geo_index
        end
      end
    end
  end
end
