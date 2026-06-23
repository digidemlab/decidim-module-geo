# frozen_string_literal: true

module Decidim
  module Geo
    module Admin
      class OrganizationConfigForm < Decidim::Form
        include Decidim::Toggle::ModuleConfigForm
        include Decidim::Toggle::ExposeAttributesToJs

        self.module_config_name = "decidim_geo"

        mimic :organization

        attribute :enabled, :boolean
        attribute :search_bar, :boolean

        expose_to_javascript :enabled, :search_bar

        validate :coerce_search_bar_when_disabled

        private

        def coerce_search_bar_when_disabled
          self.search_bar = false unless enabled
        end
      end
    end
  end
end
