# frozen_string_literal: true

module Decidim
  module Geo
    ##
    # Inserted on Decidim::Organization model,
    # will update Decidim::Geo::Index with the space page details (assembly, participatory process, etc.)
    module UpdateSpacePageOrganizationGeoIndex
      extend ActiveSupport::Concern
      included do
        include Decidim::Geo::UpdateGeoIndex
        def decidim_geo_manifest
          "space_pages"
        end

        ##
        # Run update on geo index only if the space_page module is installed
        # and the current organization is not a generator.
        def decidim_geo_enabled?
          id? && Decidim.const_defined?("SpacePage") && !space_page_generator?
        end

        def decidim_geo_related_organization_id
          id
        end
      end
    end
  end
end
