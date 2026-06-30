# frozen_string_literal: true

module Decidim
  module Geo
    module Admin
      class OrganizationConfigForm < Decidim::Form
        include Decidim::Toggle::ModuleConfigForm
        include Decidim::Toggle::ExposeAttributesToJs

        self.module_config_name = Decidim::Geo::MODULE_NAME

        mimic :organization

        attribute :enabled, :boolean
        attribute :search_bar, :boolean

        expose_to_javascript :enabled, :search_bar

        validate :coerce_search_bar_when_disabled

        def attribute_disabled?(attribute)
          attribute.to_sym == :search_bar && !enabled
        end

        private

        def coerce_search_bar_when_disabled
          self.search_bar = false unless enabled
        end
      end
    end
  end
end
