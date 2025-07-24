# frozen_string_literal: true

Deface::Override.new(virtual_path: "decidim/participatory_processes/participatory_processes/index",
                     name: "geo_add_processes_map",
                     insert_before: "erb[silent]:contains('promoted_collection.any?')",
                     original: '208408fa22ce35bdbd0b5808e0f26b6c3a638767',
                     text: <<~ERB
                       <%= cell(
                           "decidim/geo/geo_collection_map",
                           id: "ParticipatoryProcesses",
                           hide_empty: true,
                           is_index: true
                       ) %>

                     ERB
                    )
