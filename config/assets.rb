# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_geo: "#{base_path}/app/packs/entrypoints/decidim_geo.js",
  decidim_geo_vendors: "#{base_path}/app/packs/entrypoints/decidim_geo_vendors.js"
)
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/geo/geo")
