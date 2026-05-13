# frozen_string_literal: true

module Decidim
  module Geo
    module Api
      class ProposalFilter < DefaultFilter
        def filter_past(query)
          query.where(
            "LOWER(resource_type) = LOWER(?) AND (LOWER(resource_status) IN ('rejected', 'withdrawn') OR end_date < ?)",
            manifest_name,
            15.days.ago.to_date
          )
        end

        def filter_active(query)
          query.where(
            "LOWER(resource_type) = LOWER(?) AND (LOWER(resource_status) NOT IN ('rejected', 'withdrawn') OR resource_status IS NULL)",
            manifest_name
          )
        end

        def filter_future(query)
          filter_active(query)
        end
      end
    end
  end
end
