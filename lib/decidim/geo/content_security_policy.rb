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
        ["*.osm.ch", "api.maptiler.com", "*.openstreetmap.org", "*.cartocdn.com"].each do |provider|
          content_security_policy.append_csp_directive("img-src", provider)
        end
        content_security_policy.append_csp_directive("connect-src", "*.komoot.io")
      end
    end
  end
end
