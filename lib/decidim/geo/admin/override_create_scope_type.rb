# frozen_string_literal: true

module Decidim
  module Geo
    module Admin
      module OverrideCreateScopeType
        def run_after_hooks
          scope_type = resource
          scope_type.shapefile = shapefile
          scope_type.save!
          scope_type.save!
        end

        private

        def shapefile
          Decidim::Geo::Shapefile.find_by(id: form.shapefile)
        end
      end
    end
  end
end
