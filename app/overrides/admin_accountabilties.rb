Deface::Override.new(
  virtual_path: "decidim/accountability/admin/results/_form",
  name: "geo_add_filter_helptext_to_accountability",
  insert_after: "erb[loud]:contains('form.date_field :end_date')",
  original: "78f894c296bab509e852e817b443d6e5e00cc577",
  text: <<~ERB

    <div class="help-text">
      <%= t("decidim_geo_filter_help_text", scope: "decidim.accountability.admin.results.form") %>
    </div>
  ERB
)

Deface::Override.new(
  virtual_path: "decidim/accountability/admin/results/_form",
  name: "geo_add_location_form_to_accountability",
  insert_after: ".card:nth-child(1)",
  partial: "decidim/geo/admin/overrides/location_form",
  original: "693baa0442d680189ec5a73ee7af543d9157d5a3"
)