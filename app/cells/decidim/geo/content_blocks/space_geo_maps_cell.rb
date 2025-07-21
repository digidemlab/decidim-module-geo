# frozen_string_literal: true

module Decidim
  module Geo
    module ContentBlocks
      class SpaceGeoMapsCell < GeoMapsCell
        def initialize(*args, **kwargs)
          super(*args, **kwargs)
          @options[:is_index] = false
          if current_participatory_space?
            @options[:id] = "Space##{current_participatory_space.id}"
          end
        end
      end
    end
  end
end
