# frozen_string_literal: true

module ReplaceAccountabilityMap
  Deface::Override.new(virtual_path: "decidim/accountability/results/home",
                       name: "geo_add_accountability_map",
                       replace: "erb[silent]:contains('if Decidim::Map.available?(:geocoding, :dynamic) && component_settings.geocoding_enabled?')",
                       closing_selector: "erb[silent]:contains('end')",
                       text: <<~ERB
                         <% if current_organization.geo_enabled? %>
                           <%= cell("decidim/geo/content_blocks/geo_maps", current_participatory_space,
                                      id: "Accountability",
                                      hide_empty: true,
                                      is_index: false,
                                      filters: if current_participatory_space.taxonomies.present?
                                                 taxonomy = current_participatory_space.taxonomies.select { |t| t.shapedata.present? }
                                                 [{ taxonomyFilter: { taxonomyId: taxonomy.sole.id } }]
                                               else
                                                 []
                                               end,
                                      taxonomies: if current_participatory_space.taxonomies.present?
                                                    [current_participatory_space.taxonomies.select { |t| t.shapedata.present? }]
                                                  else
                                                    []
                                                  end
                                    )
                           %>
                         <% else %>
                           <% if Decidim::Map.available?(:geocoding, :dynamic) && component_settings.geocoding_enabled? %>
                             <div class="accountability__map">
                               <%= cell "decidim/map", @all_geocoded_results, metadata_card: "decidim/accountability/result_metadata" %>
                             </div>
                           <% end %>
                         <% end %>
                       ERB
                      )
end
