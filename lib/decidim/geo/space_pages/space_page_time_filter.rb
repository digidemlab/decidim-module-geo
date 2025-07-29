# frozen_string_literal: true

module Decidim
  module Geo
    ##
    # This filter does not filter anything. Space Page (Organization) will be shown in the map, 
    # no matter the time filter.
    class SpacePageTimeFilter < Api::GenericFilter
      def filter_past(query)
        query
      end

      def filter_active(query)
        query
      end

      def filter_future(query)
        query
      end
    end
  end
end
