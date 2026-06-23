# frozen_string_literal: true

require "active_storage"

module Decidim
  module Geo
    class GeoDatasourceType < Decidim::Api::Types::BaseObject
      description "A datasource for all decidim geo support"

      field :component_id, ID, null: true, description: "The ID of the component this resource belongs to."
      field :coordinates, Decidim::Geo::GeoCoordinatesType, null: true, description: "The geographic coordinates (latitude and longitude) of the resource."
      field :description_html, Decidim::Core::TranslatedFieldType, null: true, description: "The full description of the resource, formatted in HTML."
      field :end_date, GraphQL::Types::ISO8601Date, null: true, description: "The date when the resource or event ends."
      field :extended_data, GraphQL::Types::JSON, null: true, description: "Additional metadata stored as a JSON object."
      field :geo_taxonomy_id, ID, null: true, description: "The ID of the associated geographic taxonomy term."
      field :id, ID, null: false, description: "The unique identifier for this resource."
      field :image_url, String, null: true, description: "The URL of the main image associated with the resource."
      field :participatory_space_id, ID, null: true, description: "The ID of the participatory space this resource is part of."
      field :participatory_space_type, String, null: true, description: "The class name of the participatory space (e.g., 'Decidim::Assembly')."
      field :resource_id, ID, null: false, description: "The unique identifier of the underlying resource record."
      field :resource_type, String, null: false, description: "The class name of the resource (e.g., 'Decidim::Meetings::Meeting')."
      field :resource_url, String, null: false, description: "The public URL to access the resource on the platform."
      field :short_description, Decidim::Core::TranslatedFieldType, null: true, description: "A brief summary of the resource."
      field :start_date, GraphQL::Types::ISO8601Date, null: true, description: "The date when the resource or event starts."
      field :title, Decidim::Core::TranslatedFieldType, null: true, description: "The main title of the resource."
    end
  end
end
