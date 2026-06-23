# frozen_string_literal: true

module ReplaceDefaultMeetingsMap
  # Meetings
  Deface::Override.new(virtual_path: "decidim/meetings/shared/_index",
                       name: "geo_replace_default_meetings_map",
                       replace: "erb[silent]:contains('if display_map')",
                       closing_selector: "erb[silent]:contains('end')",
                       text: <<~ERB
                         <% if current_organization.geo_enabled? %>
                           <% if defined?(current_participatory_space) && current_participatory_space.present? %>
                             <%= cell("decidim/geo/content_blocks/geo_maps", current_participatory_space,
                                 id: "Meetings",
                                 hide_empty: true,
                                 is_index: false,
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
                             ) %>
                           <% else %>
                             <div class="meeting-list__map">
                               <%= cell "decidim/map", search.result, metadata_card: "decidim/meetings/meeting_card_metadata" %>
                             </div>
                           <% end %>
                         <% else %>
                           <div class="meeting-list__map">
                             <%= cell "decidim/map", search.result, metadata_card: "decidim/meetings/meeting_card_metadata" %>
                           </div>
                         <% end %>
                       ERB
                      )
end
