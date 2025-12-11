# frozen_string_literal: true
class AddOrganizationToGeoModels < ActiveRecord::Migration[7.0]
  def change
    # Add the reference, accepting null values at first
    add_reference :decidim_geo_configs, :decidim_organization, null: true, index: { name: "index_decidim_geo_configs_on_organization_id" }
    add_reference :decidim_geo_indexes, :decidim_organization, null: true, index: { name: "index_decidim_geo_indexes_on_organization_id" }
    add_reference :decidim_geo_no_indexes, :decidim_organization, null: true, index: { name: "index_decidim_geo_no_indexes_on_organization_id" }
    # Update all the reference to first found organization (previous defaults)
    first_organization = Decidim::Organization.first
    if first_organization
      Decidim::Geo::GeoConfig.find_each do |geo_config|
        geo_config.update(decidim_organization_id: first_organization.id)
      end
      Decidim::Geo::Index.find_each do |index|
        index.update(decidim_organization_id: first_organization.id)
      end
      Decidim::Geo::NoIndex.find_each do |no_index|
        no_index.update(decidim_organization_id: first_organization.id)
      end
    end
    # Constraint references to avoid null values
    change_column_null :decidim_geo_configs, :decidim_organization_id, false
    change_column_null :decidim_geo_indexes, :decidim_organization_id, false
    change_column_null :decidim_geo_no_indexes, :decidim_organization_id, false
  end
end
