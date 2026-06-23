# frozen_string_literal: true

module Decidim
  module Geo
    class GeoTaxonomyApiType < Decidim::Api::Types::BaseObject
      description "A geo taxonomy"

      field :children, [Decidim::Geo::GeoTaxonomyApiType, { null: true }], description: "Descendants of this taxonomy", null: false
      field :geom, GraphQL::Types::JSON, null: true, description: "The geometric data representing the shape or boundary, typically in GeoJSON format."
      field :id, ID, null: false, description: "The unique identifier for this record."
      field :name, Decidim::Core::TranslatedFieldType, description: "The graphql_name of this taxonomy.", null: false
      field :parent, Decidim::Geo::GeoTaxonomyApiType, description: "This taxonomy's parent taxonomy.", null: true

      def geom
        RGeo::GeoJSON.encode(object.shapedata.geom) unless object.shapedata.nil?
      end

      delegate :name, to: :object
    end
  end
end
