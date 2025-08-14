# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "decidim/admin/components/_form",
  name: "geo_add_avoid_index_component",
  insert_bottom: "#accordion-title .card-section",
  text: <<~ERB
    <% if ::Decidim::Geo.registry.active_manifests(&:keys).any? {|manifest_name| manifest_name.to_s == form.object.manifest.name.to_s && enable_view? } %>
        <div class="decidim-geo decidim-geo--admin row column">
        <%#{" "}
            space = form.object.participatory_space
            has_process_group = space.respond_to?(:participatory_process_group) ? space.participatory_process_group.present? : nil
            label = if has_process_group
                        "decidim_geo_avoid_index_within_group"
                    else
                        "decidim_geo_avoid_index"
                    end
            space_name = space.title[locale.to_s]
            space_name = space.participatory_process_group.title[locale.to_s] if has_process_group
        %>
            <%= form.check_box :decidim_geo_avoid_index, label: t(label, scope: "activemodel.attributes.component", space_name: space_name) %>
            <p class="help-text" style="transform: translateY(-0.5rem)"><%= t("geo_avoid_index", scope: "decidim.admin.components.form") %></p>
        </div>
    <% else %>
        <%= form.hidden_field :decidim_geo_avoid_index, value: false %>
    <% end %>
  ERB
)
