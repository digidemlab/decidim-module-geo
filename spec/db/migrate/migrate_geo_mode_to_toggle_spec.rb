# frozen_string_literal: true

require "spec_helper"
require Rails.root.join("../../db/migrate/20260618120000_migrate_geo_mode_to_toggle")

describe MigrateGeoModeToToggle do
  subject(:migrate_up) { migration.migrate(:up) }

  let(:migration) { described_class.new }
  let!(:enabled_org) { create(:organization) }
  let!(:disabled_org) { create(:organization) }
  let!(:no_settings_org) { create(:organization) }

  class GeoSettings < ApplicationRecord
    self.table_name = "decidim_geo_geo_settings"

    belongs_to :organization,
               class_name: "Decidim::Organization",
               foreign_key: :decidim_organization_id,
               optional: true
  end

  before do
    skip "geo_settings table not present" unless ActiveRecord::Base.connection.table_exists?(:decidim_geo_geo_settings)

    GeoSettings.create!(organization: enabled_org, geo_mode: "enabled_empty")
    GeoSettings.create!(organization: disabled_org, geo_mode: "disabled")
  end

  it "migrates geo_mode to toggle config and drops geo_settings" do
    migrate_up

    expect(ActiveRecord::Base.connection.table_exists?(:decidim_geo_geo_settings)).to be(false)
    expect(Decidim::Toggle.config_for(enabled_org.reload, :decidim_geo)[:enabled]).to be(true)
    expect(Decidim::Toggle.config_for(disabled_org.reload, :decidim_geo)[:enabled]).to be(false)
    expect(Decidim::Toggle.config_for(no_settings_org.reload, :decidim_geo)[:enabled]).to be(false)
  end
end
