# frozen_string_literal: true

module Decidim
  module Geo
    class GeoDatesType < Decidim::Api::Types::BaseObject
      description "A geo content block config"

      field :lat, Integer, null: false, description: "The latitude coordinate of the location."
      field :lng, Integer, null: false, description: "The longitude coordinate of the location."
      field :zoom, Integer, null: false, description: "The map zoom level, where higher numbers indicate a closer view."
    end
  end
end
