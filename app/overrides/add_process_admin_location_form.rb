# frozen_string_literal: true

Deface::Override.new(virtual_path: "decidim/participatory_processes/admin/participatory_processes/_form",
                     name: "geo_add_location_form_processes",
                     insert_before: "#accordion-metadata",
                     partial: "decidim/geo/admin/overrides/location_form")
