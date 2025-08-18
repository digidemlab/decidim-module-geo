# frozen_string_literal: true

Deface::Override.new(virtual_path: "decidim/accountability/results/home",
                     name: "geo_add_accountability_map",
                     insert_before: ".layout-main__section:has(erb[loud]:contains('component_settings.intro'))",
                     text: <<~ERB
                       <%= cell("decidim/geo/content_blocks/geo_maps", current_participatory_space,
                                  id: "Accountability",
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
                                ) %>
                     ERB
                    )
