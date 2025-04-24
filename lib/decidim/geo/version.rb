# frozen_string_literal: true

module Decidim
  # This holds the decidim_geo version.
  module Geo
    def self.version
      "0.3.0"
    end

    def self.decidim_version
      [">= 0.29"].freeze
    end
  end
end
