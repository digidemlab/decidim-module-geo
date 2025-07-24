# frozen_string_literal: true

# Meetings
Deface::Override.new(virtual_path: "decidim/proposals/proposals/index",
                     name: "geo_replace_default_proposals_map",
                     replace: "erb[silent]:contains('if Decidim::Map.available?')",
                     closing_selector: "erb[silent]:contains('end')",
                     text: <<~ERB
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
                     ERB
                    )
