# frozen_string_literal: true

module AddAssemblyMap
  Deface::Override.new(virtual_path: "decidim/assemblies/assemblies/index",
                       name: "geo_add_assemblies_map",
                       insert_before: "erb[silent]:contains('promoted_assemblies.any?')",
                       text: <<~ERB
                         <% if current_organization.geo_enabled? %>
                           <%= cell(
                               "decidim/geo/geo_collection_map",
                               id: "Assemblies",
                               hide_empty: true,
                               is_index: true,
                           ) %>
                         <% end %>
                       ERB
                      )
end
