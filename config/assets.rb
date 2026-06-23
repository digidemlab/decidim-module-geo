# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Shakapacker.register_path("#{base_path}/app/packs")
Decidim::Shakapacker.register_entrypoints(
  decidim_geo: "#{base_path}/app/packs/entrypoints/decidim_geo.js",
  decidim_geo_vendors: "#{base_path}/app/packs/entrypoints/decidim_geo_vendors.js"
)
Decidim::Shakapacker.register_stylesheet_import("stylesheets/decidim/geo/geo")
