# frozen_string_literal: true

module AdminAccountabilities
  Deface::Override.new(
    virtual_path: "decidim/accountability/admin/results/_form",
    name: "geo_add_filter_helptext_to_accountability",
    insert_after: "erb[loud]:contains('form.date_field :end_date')",
    text: <<~ERB
      <% if current_organization.geo_enabled? %>
        <div class="help-text">
          <%= t("decidim_geo_filter_help_text", scope: "decidim.accountability.admin.results.form") %>
        </div>
      <% end %>
    ERB
  )

  Deface::Override.new(
    virtual_path: "decidim/accountability/admin/results/_form",
    name: "geo_add_location_form_to_accountability",
    insert_after: ".card:nth-child(1)",
    text: <<~ERB
      <% if current_organization.geo_enabled? %>
        <%= render partial: "decidim/geo/admin/overrides/location_form", locals: { form: } %>
      <% end %>
    ERB
  )

  Deface::Override.new(
    virtual_path: "decidim/accountability/admin/results/_form",
    name: "geo_remove_geocoding_field_form_to_accountability",
    remove: "erb[silent]:contains('if @form.geocoding_enabled?')",
    closing_selector: "erb[silent]:contains('end')"
  )
end
