# frozen_string_literal: true

module Decidim
  module Geo
    ##
    # This filter does not filter anything. Space Page (Organization) will be shown in the map,
    # no matter the time filter.
    class SpacePageTimeFilter < Api::GenericFilter
      def filter_past(query)
        default_filter(query)
      end

      def filter_active(query)
        default_filter(query)
      end

      def filter_future(query)
        default_filter(query)
      end

      def default_filter(query)
        query.where(resource_type: manifest_name)
      end
    end
  end
end
