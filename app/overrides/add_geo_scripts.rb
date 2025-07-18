# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "layouts/decidim/_head",
  name: "geo_add_scripts",
  insert_after: "erb[loud]:contains('append_stylesheet_pack_tag')",
  text: <<~ERB
    <%= append_javascript_pack_tag "decidim_geo", defer: false %>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />

  ERB
)
