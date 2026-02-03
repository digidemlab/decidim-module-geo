# frozen_string_literal: true

module Decidim
  module Geo
    # To hide map from components
    class HideMap < ApplicationRecord
      self.table_name = "decidim_geo_hide_map"
      belongs_to :decidim_component, foreign_key: :decidim_component_id, class_name: "Decidim::Component" 
      belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization"
    end
  end
end
