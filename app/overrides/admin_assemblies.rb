

Deface::Override.new(
  virtual_path: "decidim/assemblies/admin/assemblies/_form",
  name: "geo_add_location_form_to_assemblies",
  insert_after: "#accordion-duration",
  partial: "decidim/geo/admin/overrides/location_form",
  original: "e75314984c2d467e25ef8838994acdcc14af72fe"
)
