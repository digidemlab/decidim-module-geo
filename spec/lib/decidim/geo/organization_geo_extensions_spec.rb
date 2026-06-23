# frozen_string_literal: true

require "spec_helper"

describe Decidim::Geo::OrganizationGeoExtensions do
  let(:organization) { create(:organization) }

  describe "#geo_enabled?" do
    it "returns false when no toggle config row exists" do
      expect(organization.geo_enabled?).to be(false)
    end

    it "returns true when toggle enabled is true" do
      seed_geo_toggle(organization, enabled: true)

      expect(organization.geo_enabled?).to be(true)
    end
  end

  describe "#geo_search_enabled?" do
    it "returns false when no toggle config row exists" do
      expect(organization.geo_search_enabled?).to be(false)
    end

    it "returns false when geo is enabled but search_bar is false" do
      seed_geo_toggle(organization, enabled: true, search_bar: false)

      expect(organization.geo_search_enabled?).to be(false)
    end

    it "returns true when geo and search_bar are enabled" do
      seed_geo_toggle(organization, enabled: true, search_bar: true)

      expect(organization.geo_search_enabled?).to be(true)
    end
  end
end
