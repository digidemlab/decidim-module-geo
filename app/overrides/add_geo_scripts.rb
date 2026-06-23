# frozen_string_literal: true

module AddGeoScripts
  Deface::Override.new(
    virtual_path: "layouts/decidim/_head",
    name: "geo_set_meta_scale",
    replace: "meta[name='viewport']",
    text: <<~ERB
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    ERB
  )

  Deface::Override.new(
    virtual_path: "layouts/decidim/footer/_mini",
    name: "geo_add_scripts",
    insert_after: ".mini-footer",
    text: <<~ERB
      <% if current_organization.geo_enabled? %>
        <%= append_javascript_pack_tag "decidim_geo" %>
        <%= prepend_javascript_pack_tag "decidim_geo_vendors", defer: false %>
      <% end %>
    ERB
  )
end
