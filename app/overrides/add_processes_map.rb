Deface::Override.new(virtual_path: "decidim/participatory_processes/participatory_processes/index",
                     name: "geo_add_processes_map",
                     insert_before: "erb[silent]:contains('promoted_collection.any?')",
                     text: <<~ERB
<%= cell(
    "decidim/geo/geo_collection_map", 
    id: "ParticipatoryProcesses",
    hide_empty: true,
    is_index: true,
    is_group: false
) %>

                      ERB
                    )
