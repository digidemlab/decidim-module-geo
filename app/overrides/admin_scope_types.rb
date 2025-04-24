Deface::Override.new(virtual_path: "decidim/admin/scope_types/index",
                     name: "add_scope_types_admin_shapedata_column_thead",
                     insert_after: "th:has(erb[loud]:contains('models.scope_type.fields.plural'))",
                     text: "<th>Shapefile Name</th>"
)

Deface::Override.new(virtual_path: "decidim/admin/scope_types/index",
                     name: "add_scope_types_admin_shapedata_column_tbody",
                     insert_before: "td.table-list__actions",
                     text: "<td><%= scope_type.shapefile.title unless scope_type.shapefile.nil?  %></td>"
)

Deface::Override.new(virtual_path: "decidim/admin/scope_types/_form",
                     name: "add_scope_types_admin_shapedata_input",
                     insert_after: "div.row:has(erb[loud]:contains(':plural'))",
                     text: <<~ERB
      <div class="row column">
          <%= form.collection_select :shapefile, Decidim::Geo::Shapefile.all, :id, :title, :include_blank => true %>
      </div>
ERB
)
