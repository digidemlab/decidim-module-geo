# frozen_string_literal: true

module Decidim
  module Geo
    module ContentSecurityPolicy
      extend ActiveSupport::Concern

      included do
        after_action :append_decidim_geo_csp
      end

      private

      def append_decidim_geo_csp
        # Allow tiles for most of the providers
        # https://wiki.openstreetmap.org/wiki/Raster_tile_providers
        [
          "*.osm.ch",
          "*.openstreetmap.de",
          "*.memomaps.de",
          "tiles.stadiamaps.com",
          "maps.clockworkmicro.com",
          "tile.thunderforest.com",
          "*.opentopomap.org",
          "api.maptiler.com",
          "*.openstreetmap.org",
          "*.openstreetmap.fr",
          "*.cartocdn.com",
          "api.wikiocity.com",
          "maptiles.p.rapidapi.com",
          "retina-tiles.p.rapidapi.com",
          "cdn.lima-labs.com",
          "tile.tracestrack.com",
          "maps.geoapify.com",
          "tiles.stadiamaps.com",
          "tile.openstreetmap.be",
          "map.atownsend.org.uk"
        ].each do |provider|
          content_security_policy.append_csp_directive("img-src", provider)
        end
        content_security_policy.append_csp_directive("connect-src", "*.komoot.io")
      end
    end
  end
end
