# frozen_string_literal: true

require "spec_helper"

describe Decidim::Geo::Admin::OrganizationConfigForm do
  let(:organization) { create(:organization) }

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
