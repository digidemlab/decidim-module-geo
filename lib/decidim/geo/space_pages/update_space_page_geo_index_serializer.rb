# frozen_string_literal: true

module Decidim
  module Geo
    class UpdateSpacePageGeoIndexSerializer
      include Decidim::Geo::GenericSerializer
      def initialize(space_page)
        @resource = space_page
        @resource_id = space_page.id
      end

      def participatory_space_id
        resource.id
      end

      def participatory_space_type
        resource.manifest.name.to_s
      end

      def component_id
        nil
      end
    end
  end
end
