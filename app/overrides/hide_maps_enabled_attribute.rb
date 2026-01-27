# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "decidim/admin/components/_settings_fields",
  name: "hide_maps_enabled_attribute",
  surround: "div.row.column.mb-2",
  text: <<~ERB
    <% if field_name == :maps_enabled && current_organization.geo_enabled? %>
      <div class="hide">
        <%= render_original %>
      </div>
    <% else %>
      <%= render_original %>
    <% end %>
  ERB
)
