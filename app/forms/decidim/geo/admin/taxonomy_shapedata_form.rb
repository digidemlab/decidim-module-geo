# frozen_string_literal: true

module Decidim
  module Geo
    module Admin
      # A form object to update a shapedata with a taxonomy.
      class TaxonomyShapedataForm < Form
        attribute :taxonomy_id, Integer
        attribute :shapedata_id, Integer
      end
    end
  end
end
