# frozen_string_literal: true

class ReplaceGeoEnableWithGeoMode < ActiveRecord::Migration[7.0]
  def up
    remove_column :decidim_geo_geo_settings, :geo_enabled, :boolean

    add_column :decidim_geo_geo_settings,
               :geo_mode,
               :string,
               default: "enable_empty",
               null: false
  end

  def down
    remove_column :decidim_geo_geo_settings, :geo_mode, :string

    add_column :decidim_geo_geo_settings,
               :geo_enabled,
               :boolean,
               default: true,
               null: false
  end
end
