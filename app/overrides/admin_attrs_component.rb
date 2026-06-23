# frozen_string_literal: true

module AdminAttrsComponent
  Deface::Override.new(
    virtual_path: "decidim/admin/components/_form",
    name: "geo_add_attrs_component",
    insert_bottom: "#accordion-title .card-section",
    text: <<~ERB
      <% if current_organization.geo_enabled? && ::Decidim::Geo.registry.active_manifests(&:keys).any? {|manifest_name| manifest_name.to_s == form.object.manifest.name.to_s } %>
        <div class="decidimGeo__admin-components row column">
        <%
          space = form.object.participatory_space
          has_process_group = space.respond_to?(:participatory_process_group) ? space.participatory_process_group.present? : nil
          label = if has_process_group
                      "decidim_geo_avoid_index_within_group"
                  else
                      "decidim_geo_avoid_index"
                  end
          space_name = space.title[locale.to_s]
          space_name = space.participatory_process_group.title[locale.to_s] if has_process_group
          component_name = translated_attribute(component.name)
        %>
          <%= form.check_box :decidim_geo_avoid_index, label: t(label, scope: "activemodel.attributes.component", space_name: space_name) %>
          <p class="help-text" style="transform: translateY(-0.5rem)"><%= t("geo_avoid_index", scope: "decidim.admin.components.form") %></p>
          <%= form.check_box :decidim_geo_hide_map, label: t("activemodel.attributes.component.hide_map", component_name: ) %>
          <p class="help-text" style="transform: translateY(-0.5rem)"><%= t("decidim.admin.components.form.hide_map") %></p>
        </div>
      <% else %>
        <%= form.hidden_field :decidim_geo_avoid_index, value: false %>
      <% end %>
    ERB
  )
end
