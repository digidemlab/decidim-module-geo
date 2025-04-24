# frozen_string_literal: true

module Decidim
  module Geo
    module Admin
      module OverrideUpdateScopeCommand
        
        def run_after_hooks
          scope = resource 
          scope.shapedata = shapedata
          scope.save!
        end

        private

        def shapedata
          Decidim::Geo::Shapedata.find_by(id: form.shapedata)
        end
      end
    end
  end
end
