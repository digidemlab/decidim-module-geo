# frozen_string_literal: true
class AddGeoEnabledToDecidimOrganizations < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_organizations, :geo_enabled, :boolean, default: true, null: false
  end
end
