# frozen_string_literal: true

FactoryBot.define do
  factory :geo_config, class: "Decidim::Geo::GeoConfig" do
    association :organization
    longitude { -46.6333 }
    latitude { -23.5505 }
    zoom { 12 }
    tile { "" }
    maptiler_api_key { "" }
    maptiler_style_id { "" }
    esri_tile_enabled { false }
    default_geoencoded_filter { :no_force_geoencoded }

    after(:build) do |config|
      config.decidim_organization_id = config.organization.id if config.organization
    end
  end
end
