# frozen_string_literal: true

Deface::Override.new(virtual_path: "decidim/assemblies/assemblies/index",
                     name: "geo_add_assemblies_map",
                     insert_before: "erb[silent]:contains('promoted_assemblies.any?')",
                     original: "315cd2561b8196b1b9bf2d8f199df31a02e12e37",
                     text: <<~ERB
                       <%= cell(
                           "decidim/geo/geo_collection_map",
                           id: "Assemblies",
                           hide_empty: true,
                           is_index: true,
                       ) %>

                     ERB
                    )
