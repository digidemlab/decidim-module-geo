# frozen_string_literal: true

module GeoToggleHelpers
  def seed_geo_toggle(organization, enabled:, search_bar: false)
    Decidim::Toggle.save_config!(
      organization,
      :decidim_geo,
      { enabled:, search_bar: }
    )
  end
end

RSpec.configure do |config|
  config.include GeoToggleHelpers
end
