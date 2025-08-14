# frozen_string_literal: true

# Meetings
Deface::Override.new(virtual_path: "decidim/proposals/proposals/index",
                     name: "geo_replace_default_proposals_map",
                     replace: "erb[silent]:contains('if Decidim::Map.available?')",
                     closing_selector: "erb[silent]:contains('end')",
                     text: <<~ERB
                      <% if enable_view? %>
                       <%= cell("decidim/geo/content_blocks/geo_maps", current_participatory_space,
                           id: "Proposals",
                           hide_empty: true,
                           is_index: false,
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
                       ) %>#{"                     "}
                      <% else %>
                        <% if Decidim::Map.available?(:geocoding, :dynamic) && component_settings.geocoding_enabled? %>
                          <div class="proposal-list__map">
                            <%= dynamic_map_for proposals_data_for_map(@proposals) do %>
                              <template id="marker-popup">
                                <div class="space-y-6">
                                  <a href="${link}" class="card__list">
                                    <div class="card__list-content">
                                      <h3 class="h4 card__list-title">${title}</h3>
                                      <div class="card__list-metadata">
                                        {{each JSON.parse(items)}}
                                          <span>{{html icon}}{{html text}}</span>
                                        {{/each}}
                                      </div>
                                    </div>
                                  </a>
                                </div>
                              </template>
                            <% end %>
                          </div>
                        <% end %>
                      <% end %>
                    ERB
                    )
