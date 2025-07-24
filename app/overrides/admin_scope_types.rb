# frozen_string_literal: true

Deface::Override.new(virtual_path: "decidim/admin/scope_types/index",
                     name: "geo_add_scope_types_admin_shapedata_column_thead",
                     insert_after: "th:has(erb[loud]:contains('models.scope_type.fields.plural'))",
                     original: 'b27aa1333425e577b261aafd5cf2bf48f5258914',
                     text: "<th>Shapefile Name</th>")

Deface::Override.new(virtual_path: "decidim/admin/scope_types/index",
                     name: "add_scope_types_admin_shapedata_column_tbody",
                     insert_before: "td.table-list__actions",
                     original: 'e1559ba0a68269d6e7dcc22640da41f7be221c54',
                     text: "<td><%= scope_type.shapefile.title unless scope_type.shapefile.nil?  %></td>")

Deface::Override.new(virtual_path: "decidim/admin/scope_types/_form",
                     name: "add_scope_types_admin_shapedata_input",
                     insert_after: "div.row:has(erb[loud]:contains(':plural'))",
                     original: '0c30ef61189f377aae341ad55a309642451fe663',
                     text: <<~ERB
                       <div class="row column">
                           <%= form.collection_select :shapefile, Decidim::Geo::Shapefile.all, :id, :title, :include_blank => true %>
                       </div>
                     ERB
                    )
