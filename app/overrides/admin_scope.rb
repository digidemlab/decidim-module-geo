

Deface::Override.new(virtual_path: "decidim/admin/scopes/index",
                     name: "add_scope_admin_shapedata_column_thead",
                     insert_after: "th:has(erb[loud]:contains('models.scope.fields.scope_type'))",
                     text: "<th>Shapedata</th>"
)

Deface::Override.new(virtual_path: "decidim/admin/scopes/index",
                     name: "add_scope_admin_shapedata_column_tbody",
                     insert_before: "td.table-list__actions",
                     text: "<td><%= shapedata_name(scope) unless scope.shapedata.nil? %></td>"
)
Deface::Override.new(virtual_path: "decidim/admin/scopes/_form",
                     name: "add_scope_admin_shapedata_input",
                     insert_after: "div.row:has(erb[loud]:contains(':scope_type_id'))",
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