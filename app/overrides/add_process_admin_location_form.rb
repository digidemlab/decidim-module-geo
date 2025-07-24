# frozen_string_literal: true

Deface::Override.new(virtual_path: "decidim/participatory_processes/admin/participatory_processes/_form",
                     name: "geo_add_location_form_processes",
                     insert_before: "#accordion-metadata",
                     original: 'eb3f456ad7a4d13e14e8c6bc8e43e8d0bc3102f0',
                     partial: "decidim/geo/admin/overrides/location_form")
