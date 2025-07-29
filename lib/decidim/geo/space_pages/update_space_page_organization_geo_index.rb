# frozen_string_literal: true

module Decidim
  module Geo
    module UpdateSpacePageOrganizationGeoIndex
      extend ActiveSupport::Concern
      included do
        include Decidim::Geo::UpdateGeoIndex
        def decidim_geo_manifest
          "space_pages"
        end
      end
    end
  end
end
