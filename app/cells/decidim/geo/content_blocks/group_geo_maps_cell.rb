# frozen_string_literal: true

module Decidim
  module Geo
    module ContentBlocks
      class GroupGeoMapsCell < GeoMapsCell
        def initialize(*args, **kwargs)
          super(*args, **kwargs)
          group = Decidim::ParticipatoryProcessGroup.find(
            model.scoped_resource_id
          )
          @options[:is_index] = false
          @options[:filters].concat(
            group.participatory_processes.published.ids.map { |id| { process_filter: { id: } } }
          )
        end
      end
    end
  end
end
