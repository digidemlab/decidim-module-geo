# frozen_string_literal: true

module Decidim
  module Geo
    # This module contains all the domain logic associated to Decidim's Geo
    # component admin panel.
    module ComponentHideMapAttr
      extend ActiveSupport::Concern
      included do
        has_one :decidim_geo_hide_map, as: :decidim_component, class_name: "Decidim::Geo::HideMap"
        def decidim_geo_hide_map?
          decidim_geo_hide_map&.hide_map
        end
      end
    end
  end
end
