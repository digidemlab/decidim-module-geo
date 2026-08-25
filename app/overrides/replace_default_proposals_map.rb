# frozen_string_literal: true

module ReplaceDefaultProposalsMap
  # Meetings
  Deface::Override.new(virtual_path: "decidim/proposals/proposals/index",
                       name: "geo_replace_default_proposals_map",
                       replace: "erb[silent]:contains('if Decidim::Map.available?')",
                       closing_selector: "erb[silent]:contains('end')",
                       text: <<~ERB
                         <% if current_organization.geo_enabled? %>
                           <%= cell("decidim/geo/content_blocks/geo_maps", current_participatory_space,
                               id: "Proposals",
                               hide_empty: true,
                               is_index: false,
                               filters: if current_participatory_space.taxonomies.present?
                                         taxonomy = current_participatory_space.taxonomies.select { |t| t.shapedata.present? }
                                         taxonomy.present? ? [{ taxonomyFilter: { taxonomyId: taxonomy.first.id } }] : []
                                        else
                                            []
                                        end,
                               taxonomies: if current_participatory_space.taxonomies.present?
                                            taxonomy = current_participatory_space.taxonomies.select { |t| t.shapedata.present? }
                                            taxonomy.present? ? [taxonomy.first.id] : nil
                                           else
                                               []
                                           end
                           ) %>
                         <% else %>
                           <% if Decidim::Map.available?(:geocoding, :dynamic) && component_settings.geocoding_enabled? %>
                             <div class="proposal-list__map">
                               <%= cell "decidim/map", @proposals, metadata_card: "decidim/proposals/proposal_metadata" %>
                             </div>
                           <% end %>
                         <% end %>
                       ERB
                      )
end
