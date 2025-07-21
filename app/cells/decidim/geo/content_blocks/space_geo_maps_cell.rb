# frozen_string_literal: true

module Decidim
  module Geo
    module ContentBlocks
      class SpaceGeoMapsCell < GeoMapsCell
        def initialize(*args, **kwargs)
          super(*args, **kwargs)
          @options[:is_index] = false
          @options[:id] = "Space#{current_participatory_space_manifest.parameterize}#{current_participatory_space.id}"
          # Scope on the current process
          if current_participatory_space_manifest == "participatory_processes"
            @options[:filters].push({
                                      process_filter: { id: current_participatory_space.id }
                                    })
          end
          # Scope on the current assembly and all its children
          return unless current_participatory_space_manifest == "assemblies"

          @options[:filters].concat(
            [{ assembly_filter: { id: current_participatory_space.id } }],
            Decidim::Assembly.published.where(
              "parents_path ~ ?", "*.*{#{current_participatory_space.id}}.*"
            ).pluck(:id).map { |id| { assembly_filter: { id: } } }
          )
        end

        private

        def current_participatory_space_manifest
          current_participatory_space.manifest.name.to_s
        end
      end
    end
  end
end
