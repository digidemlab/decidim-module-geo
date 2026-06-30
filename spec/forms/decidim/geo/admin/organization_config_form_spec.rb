# frozen_string_literal: true

require "spec_helper"

describe Decidim::Geo::Admin::OrganizationConfigForm do
  let(:organization) { create(:organization) }

  describe "module name" do
    it "matches the toggle registration" do
      expect(described_class.module_config_name).to eq(Decidim::Geo::MODULE_NAME)
    end
  end

  describe "labels" do
    it "uses decidim_toggle.system.decidim_geo scope for attribute names" do
      expect(described_class.human_attribute_name(:enabled)).to eq(
        I18n.t("decidim_toggle.system.decidim_geo.enabled")
      )
      expect(described_class.human_attribute_name(:search_bar)).to eq(
        I18n.t("decidim_toggle.system.decidim_geo.search_bar")
      )
    end
  end

  describe "#attribute_disabled?" do
    it "disables search_bar when geo is not enabled" do
      form = described_class.from_params(organization: { enabled: false, search_bar: true })

      expect(form.attribute_disabled?(:search_bar)).to be(true)
    end

    it "allows search_bar when geo is enabled" do
      form = described_class.from_params(organization: { enabled: true, search_bar: true })

      expect(form.attribute_disabled?(:search_bar)).to be(false)
    end
  end

  describe "validations" do
    it "coerces search_bar to false when enabled is false" do
      form = described_class.from_params(
        organization: { enabled: false, search_bar: true }
      ).with_context(current_organization: organization)

      expect(form).to be_valid
      expect(form.search_bar).to be(false)
    end

    it "accepts enabled and search_bar when both are true" do
      form = described_class.from_params(
        organization: { enabled: true, search_bar: true }
      ).with_context(current_organization: organization)

      expect(form).to be_valid
    end
  end
end
