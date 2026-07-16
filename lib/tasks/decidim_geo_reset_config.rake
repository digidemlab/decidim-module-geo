# frozen_string_literal: true

require "decidim/geo/maintenance/reset_config"

namespace :decidim_geo do
  desc "Reset decidim-geo map config (dry-run by default; use DRY_RUN=0 to apply)"
  task reset_config: :environment do
    dry_run = ENV.fetch("DRY_RUN", "1") != "0"

    Decidim::Geo::Maintenance::ResetConfig.new(dry_run:).run!
  end
end
