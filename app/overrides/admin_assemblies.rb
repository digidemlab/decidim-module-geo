

Deface::Override.new(
  virtual_path: "decidim/assemblies/admin/assemblies/_form",
  name: "geo_add_location_form_to_assemblies",
  insert_after: "#accordion-duration",
  partial: "decidim/geo/admin/overrides/location_form"
)
