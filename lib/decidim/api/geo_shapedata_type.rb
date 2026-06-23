# frozen_string_literal: true

module Decidim
  module Geo
    # GeoShapedataType
    class GeoShapedataType < Decidim::Api::Types::BaseObject
      description "A shapefile data"

      field :data, GraphQL::Types::JSON, null: true, description: "Additional attributes or metadata stored as a JSON object."
      field :geom, GraphQL::Types::JSON, null: true, description: "The geometric representation (e.g., Polygon, MultiPolygon) of the area in GeoJSON format."
      field :id, ID, null: false, description: "The unique identifier for this geographic record."

      def geom
        RGeo::GeoJSON.encode(object.geom)
      end
    end
  end
end
