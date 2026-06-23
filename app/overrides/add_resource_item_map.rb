# frozen_string_literal: true

module AddResourceItemMap
  # Meetings
  Deface::Override.new(virtual_path: "layouts/decidim/shared/_layout_item",
                       name: "geo_add_resource_item_map",
                       insert_before: "div[role=complementary]",
                       text: <<~ERB
                         <% if current_organization.geo_enabled? %>
                           <% component_manifest = current_component.manifest_name %>
                           <%= cell("decidim/geo/content_blocks/geo_maps", current_participatory_space,
                               id: (component_manifest + "_item").camelize,
                               hide_empty: true,
                               is_index: false,
                               container_classnames: "decidimGeo__container--item",
                               filters: if current_participatory_space.taxonomies.present?
                                           taxonomy = current_participatory_space.taxonomies.select { |t| t.shapedata.present? }
                                           [{ taxonomyFilter: { taxonomyId: taxonomy.sole.id } }]
                               else
                                   []
                               end,
                               taxonomies: if current_participatory_space.taxonomies.present?
                                             taxonomy = current_participatory_space.taxonomies.select { |t| t.shapedata.present? }
                                             [taxonomy.sole.id]
                               else
                                   []
                               end
                           ) unless ["budgets", "surveys"].include? component_manifest%>#{"                     "}
                         <% end %>
                       ERB
                      )
end
