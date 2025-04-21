# frozen_string_literal: true
# Meetings
Deface::Override.new(virtual_path: "layouts/decidim/shared/_layout_item",
                     name: "add_resource_item_map",
                     insert_before: "div[role=complementary]",
                     text: <<~ERB

<% component_manifest = current_component.manifest_name %>
<%= cell("decidim/geo/content_blocks/geo_maps", current_participatory_space, 
    id: (component_manifest + "_item").camelize,
    hide_empty: true,
    is_index: false,
    is_group: false,
    container_classnames: "decidimGeo__container--item",
    filters: if current_participatory_space.scope.present?
        [
          { scopeFilter: { scopeId: current_participatory_space.scope.id } }
        ]
    else 
        []
    end,
    scopes: if current_participatory_space.scope.present?
        [current_participatory_space.scope.id]
    else
        []
    end
) unless ["budgets", "surveys"].include? component_manifest%>                     
ERB
)
