# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Geo
    describe GeoConfig do
      subject { build(:geo_config, organization:) }

      let(:organization) { create(:organization) }

      # Validation Tests
      describe "validations" do
        # Test longitude presence
        it "is invalid without longitude" do
          geo_config = build(:geo_config, longitude: nil, organization:)
          expect(geo_config).not_to be_valid
          expect(geo_config.errors[:longitude]).to include("cannot be blank")
        end

        # Test latitude presence
        it "is invalid without latitude" do
          geo_config = build(:geo_config, latitude: nil, organization:)
          expect(geo_config).not_to be_valid
          expect(geo_config.errors[:latitude]).to include("cannot be blank")
        end

        # Test zoom presence
        it "is invalid without zoom" do
          geo_config = build(:geo_config, zoom: nil, organization:)
          expect(geo_config).not_to be_valid
          expect(geo_config.errors[:zoom]).to include("cannot be blank")
        end

        # Test organization presence (decidim_organization_id)
        it "is invalid without an organization" do
          # Build without associating an organization
          geo_config = build(:geo_config, decidim_organization_id: nil, organization: nil)
          expect(geo_config).not_to be_valid
          expect(geo_config.errors[:decidim_organization_id]).to include("cannot be blank")
        end
      end

      # Enum Tests
      describe "enums" do
        let(:geo_config) { build(:geo_config, organization:) }

        it "defines default_geoencoded_filter enum with correct values" do
          # Checks if the scope and predicate methods were created
          expect(geo_config).to respond_to(:force_geoencoded!)
          expect(geo_config).to respond_to(:no_force_geoencoded!)
          expect(geo_config).to respond_to(:force_geoencoded?)
          expect(geo_config).to respond_to(:no_force_geoencoded?)
        end

        it "defaults to no_force_geoencoded (value 1)" do
          # Checks the default value defined in your model or factory
          # If the factory doesn't define it, check the initial DB or model value
          expect(geo_config.default_geoencoded_filter).to eq("no_force_geoencoded")
          # Or check the numeric value if you prefer:
          # expect(geo_config.default_geoencoded_filter_before_type_cast).to eq(1)
        end

        it "can change state to force_geoencoded" do
          geo_config.force_geoencoded!
          expect(geo_config.default_geoencoded_filter).to eq("force_geoencoded")
          expect(geo_config.default_geoencoded_filter_before_type_cast).to eq(0)
        end
      end

      # Association Tests
      describe "associations" do
        it "belongs to an organization" do
          # Creates a config associated with an organization
          geo_config = create(:geo_config, organization:)

          # Checks if we can access the associated organization
          expect(geo_config.organization).to eq(organization)
          expect(geo_config.organization).to be_a(Decidim::Organization)
        end

        it "requires an organization to be valid" do
          # Builds a config without an organization
          geo_config = build(:geo_config, organization: nil, decidim_organization_id: nil)

          # Checks if it is invalid without the association
          expect(geo_config).not_to be_valid
          expect(geo_config.errors[:decidim_organization_id]).to include("cannot be blank")
        end

        it "stores the organization ID in the correct foreign key column" do
          geo_config = build(:geo_config, organization:)

          # Checks if the foreign key column is populated correctly
          expect(geo_config.decidim_organization_id).to eq(organization.id)
        end
      end

      # Tests for the class method .geo_config_default
      describe ".geo_config_default" do
        let(:organization) { create(:organization) }

        context "when no config exists for the organization" do
          it "creates a new GeoConfig with default values" do
            expect do
              result = described_class.geo_config_default(organization)
              expect(result).to be_persisted
              expect(result.decidim_organization_id).to eq(organization.id)
              expect(result.latitude).to eq(0)
              expect(result.longitude).to eq(0)
              expect(result.zoom).to eq(13)
              expect(result.default_geoencoded_filter).to eq("no_force_geoencoded") # Value 1 converted by enum
              expect(result.maptiler_api_key).to eq("")
              expect(result.esri_tile_enabled).to be false
            end.to change(described_class, :count).by(1)
          end
        end

        context "when a config already exists for the organization" do
          let!(:existing_config) do
            create(:geo_config, decidim_organization_id: organization.id, latitude: 50, longitude: 50)
          end

          it "returns the existing record without creating a new one" do
            expect do
              result = described_class.geo_config_default(organization)
              expect(result.id).to eq(existing_config.id)
              expect(result.latitude).to eq(50) # Keeps the original value, does not reset
            end.not_to change(described_class, :count)
          end
        end
      end

      # Tests for the class method .tile_layer_default
      describe ".tile_layer_default" do
        context "when Decidim.config.maps is blank" do
          before do
            allow(Decidim.config).to receive(:maps).and_return(nil)
          end

          it "returns an empty string" do
            expect(described_class.tile_layer_default).to eq("")
          end
        end

        context "when Decidim.config.maps is present but dynamic tile_layer url is missing" do
          before do
            allow(Decidim.config).to receive(:maps).and_return({ other: :config })
          end

          it "returns an empty string" do
            expect(described_class.tile_layer_default).to eq("")
          end
        end

        context "when Decidim.config.maps has the dynamic tile_layer url" do
          let(:expected_url) { "https://example.com/tiles/{z}/{x}/{y}.png" }

          before do
            allow(Decidim.config).to receive(:maps).and_return({
                                                                 dynamic: {
                                                                   tile_layer: {
                                                                     url: expected_url
                                                                   }
                                                                 }
                                                               })
          end

          it "returns the configured URL" do
            expect(described_class.tile_layer_default).to eq(expected_url)
          end
        end
      end
    end
  end
end
