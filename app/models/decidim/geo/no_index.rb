# frozen_string_literal: true

module Decidim
  module Geo
    # Data fo the shapfiles uploaded
    class NoIndex < ApplicationRecord
      self.table_name = "decidim_geo_no_indexes"
      belongs_to :decidim_component, class_name: "Decidim::Component"
      belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization"

      def geo_indexed?
        !no_index
      end
    end
  end
end
