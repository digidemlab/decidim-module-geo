# frozen_string_literal: true

class DecidimGeoHideMap < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_geo_hide_map do |t|
      t.boolean :hide_map, default: false, null: false
      t.integer :decidim_component_id
      t.string :decidim_component_type
      t.belongs_to :decidim_organization, foreign_key: true

      t.timestamps
    end
  end
end
