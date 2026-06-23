# frozen_string_literal: true

module Decidim
  module Geo
    class GeoShapefileType < Decidim::Api::Types::BaseObject
      description "A shapefile"

      field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "The date and time when this record was created."
      field :description, String, null: true, description: "A textual description of the shapefile or geographic area."
      field :id, ID, null: false, description: "The unique identifier for this record."
      field :shapefile, String, null: false, description: "The filename or path identifier of the uploaded shapefile."
      field :title, String, null: false, description: "The title or name of the geographic area."
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false, description: "The date and time when this record was last updated."

      def shapefile
        object.shapefile.path
      end
    end
  end
end
