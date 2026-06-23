# frozen_string_literal: true

FactoryBot.define do
  factory :shapefile, class: "Decidim::Geo::Shapefile" do
    association :organization
    title { "Test Shapefile" }
    description { "Test Description" }
    decidim_taxonomies_id { nil }
    # Add other required attributes for your Shapefile model
  end
end
