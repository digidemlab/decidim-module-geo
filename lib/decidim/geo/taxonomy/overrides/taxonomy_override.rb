# frozen_string_literal: true

module Decidim
  module Geo
    module TaxonomyOverride
      extend ActiveSupport::Concern
      included do
        has_one :shapefile, foreign_key: :decidim_taxonomies_id, class_name: "Decidim::Geo::Shapefile", inverse_of: :taxonomy
        has_one :shapedata, foreign_key: :decidim_taxonomies_id, class_name: "Decidim::Geo::Shapedata", inverse_of: :taxonomy
      end
    end
  end
end
