# frozen_string_literal: true

Deface::Override.new(virtual_path: "decidim/admin/shared/landing_page/_content_blocks",
                     name: "geo_replace_content_block_available_manifests",
                     replace: "erb[silent]:contains('available_manifests.each')",
                     closing_selector: "erb[silent]:contains('end')",
                     text: <<~ERB
                       <% available_manifests.each do |manifest| %>
                         <% next if [:geo_maps, :space_geo_maps].include?(manifest.name) && !current_organization.geo_enabled? %>
                         <li><%= link_to t(manifest.public_name_key), resource_create_url(manifest.name), method: :post %></li>
                       <% end %>
                     ERB
                    )
