# frozen_string_literal: true

module Decidim
  module Geo
    # Data fo the shapfiles uploaded
    class Shapedata < ApplicationRecord
      self.table_name = "decidim_geo_shapefile_datas"
      validates :data, presence: true
      validate :taxonomy_is_child

      validates :decidim_taxonomies_id, uniqueness: true, allow_nil: true

      belongs_to :taxonomy, inverse_of: :shapedata, optional: true, foreign_key: "decidim_taxonomies_id"

      def execute_statement(sql)
        Shapedata.connection.exec_query(sql)
      end

      def organization
        taxonomy.organization if taxonomy.present?
      end

      def shapedata?
        false
      end

      def taxonomy_is_child
        return unless taxonomy

        taxonomy.weight.positive?
      end
    end
  end
end
