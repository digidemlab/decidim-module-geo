# frozen_string_literal: true

class ReplaceGeoEnableWithGeoMode < ActiveRecord::Migration[7.0]
  class GeoSettings < ApplicationRecord
    self.table_name = "decidim_geo_geo_settings"

    belongs_to :organization,
               class_name: "Decidim::Organization",
               foreign_key: :decidim_organization_id,
               optional: true
  end

  def up
    add_column :decidim_geo_geo_settings,
               :geo_mode,
               :string,
               default: "enabled_empty",
               null: false

    Decidim::Organization.find_each do |org|
      GeoSettings.create!(organization: org, geo_mode: "enabled_empty") unless org.respond_to?(:geo_settings)
    end

    GeoSettings.find_each do |geo_setting|
      geo_enabled_value = geo_setting.read_attribute(:geo_enabled)
      geo_setting.update(geo_mode: geo_enabled_value ? "enabled_empty" : "disabled")
    end

    remove_column :decidim_geo_geo_settings, :geo_enabled, :boolean
  end

  def down
    add_column :decidim_geo_geo_settings,
               :geo_enabled,
               :boolean,
               default: true,
               null: false

    GeoSettings.find_each do |geo_setting|
      geo_enabled_value = geo_setting.geo_mode
      geo_setting.update(geo_enabled: geo_enabled_value != "disabled")
    end

    remove_column :decidim_geo_geo_settings, :geo_mode, :string
  end
end
