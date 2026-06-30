# frozen_string_literal: true

FactoryBot.define do
  factory :geo_index, class: "Decidim::Geo::Index" do
    association :organization
    resource_id { 1 }
    resource_type { "proposals" }
    title { "Indexed Resource Title" }
    short_description { "Short description of the resource." }
    description_html { "<p>Full HTML description of the resource.</p>" }
    image_url { "https://example.com/image.jpg" }
    resource_url { "https://example.com/resource" }
    resource_status { "open" }
    component_id { nil }
    participatory_space_id { nil }
    participatory_space_type { "ParticipatoryProcess" }
    geo_taxonomy_id { nil }
    start_date { Date.current }
    end_date { 1.year.from_now }
    avoid_index { false }
    extended_data { nil }
    lonlat { { x: -43.1729, y: -22.9068 } }

    trait :virtual do
      lonlat { nil }
    end

    trait :avoid_indexing do
      avoid_index { true }
    end

    trait :for_component do
      component_id { 1 }
      participatory_space_id { nil }
    end

    trait :for_space do
      component_id { nil }
      participatory_space_id { 1 }
      participatory_space_type { "ParticipatoryProcess" }
    end
  end
end
