# frozen_string_literal: true

module Decidim
  module Geo
    class GeoSettings < ApplicationRecord
      belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization", inverse_of: :geo_settings

      validates :geo_mode, inclusion: { in: %w(disabled enabled_empty enabled_copy) }
    end
  end
end
