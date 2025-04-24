Deface::Override.new(virtual_path: "decidim/assemblies/assemblies/index",
                     name: "geo_add_assemblies_map",
                     insert_before: "erb[silent]:contains('promoted_assemblies.any?')",
                     text: <<~ERB
<%= cell(
    "decidim/geo/geo_collection_map", 
    id: "Assemblies",
    hide_empty: true,
    is_index: true,
    is_group: false
) %>

                      ERB
                    )


