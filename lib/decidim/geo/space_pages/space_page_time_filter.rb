# frozen_string_literal: true

module Decidim
  module Geo
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
