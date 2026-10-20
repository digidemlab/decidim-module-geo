# frozen_string_literal: true

module Decidim
  # This holds the decidim_geo version.
  module Geo
    MODULE_NAME = "decidim_geo"

    def self.version
      "0.4.3" # DO NOT UPDATE MANUALLY
    end

    def self.decidim_version
      [">= 0.29", "< 0.32"].freeze
    end
  end
end
