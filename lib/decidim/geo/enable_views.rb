# frozen_string_literal: true

module Decidim
  module Geo
    module EnableViews
      extend ActiveSupport::Concern
      
      included do

        helper_method :enable_view?

        def enable_view?
          byebug
          return true unless current_organization.respond_to?("space_page")
          from_org = current_organization.space_page_settings_attributes["created_by_org"]
          organization = Decidim::Organization.find(from_org)
          !!organization.space_page_settings_attributes.dig("template_vars", "geo_enabled")
        end

      end
    end
  end
end
