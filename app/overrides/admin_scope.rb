# frozen_string_literal: true

Deface::Override.new(virtual_path: "decidim/admin/scopes/index",
                     name: "geo_add_scope_admin_shapedata_column_thead",
                     insert_after: "th:has(erb[loud]:contains('models.scope.fields.scope_type'))",
                     original: '735662e587c0bc59294e047106041f78921b1ce9',
                     text: "<th>Shapedata</th>")

Deface::Override.new(virtual_path: "decidim/admin/scopes/index",
                     name: "add_scope_admin_shapedata_column_tbody",
                     insert_before: "td.table-list__actions",
                     original: '55968a1416cee20ff37e885fa7b2e8a2c1f591df',
                     text: "<td><%= shapedata_name(scope) unless scope.shapedata.nil? %></td>")
Deface::Override.new(virtual_path: "decidim/admin/scopes/_form",
                     name: "add_scope_admin_shapedata_input",
                     insert_after: "div.row:has(erb[loud]:contains(':scope_type_id'))",
                     original: 'd6628e2df386be842bcc358493ae9419d5d273b9',
                     text: <<~ERB
                       <% if scope && scope.scope_type %>
                         <% unless shapedata_scope(scope).nil? %>
                           <div class="row column">
                             <%= form.collection_select :shapedata, shapedata_scope(scope), :id, :name, :include_blank => true %>
                           </div>
                         <% end %>
                       <% end %>
                     ERB
                    )
