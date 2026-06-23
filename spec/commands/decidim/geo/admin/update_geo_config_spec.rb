# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Geo
    module Admin
      describe UpdateGeoConfig do
        describe "#call" do
          let(:organization) { create(:organization) }
          let(:existing_config) { create(:geo_config, organization:) }

          # Simulates a form object with valid data
          let(:form) do
            double(
              "Form",
              longitude: -46.6333,
              latitude: -23.5505,
              zoom: 12,
              tile: "https://example.com/tiles",
              esri_tile_enabled: true,
              maptiler_api_key: "secret_key",
              maptiler_style_id: "style_123",
              only_assemblies: false,
              only_processes: true,
              focus_zoom_level: 15,
              default_geoencoded_filter: "no_force_geoencoded",
              organization: organization,
              decidim_geo_shapefiles_id: nil,
              taxonomy_id: nil,
              invalid?: false
            )
          end

          # Define the command instance, but do not call it yet
          let(:command_update) { described_class.new(existing_config, form) }
          let(:command_create) { described_class.new(nil, form) }

          context "when the form is invalid" do
            before do
              allow(form).to receive(:invalid?).and_return(true)
            end

            it "does not update the existing geo_config" do
              expect(existing_config).not_to receive(:update!)
              # Call the command explicitly inside the test
              expect { command_update.call }.not_to change(Decidim::Geo::GeoConfig, :count)
            end

            it "does not create a new geo_config" do
              expect(Decidim::Geo::GeoConfig).not_to receive(:create!)
              expect { command_create.call }.not_to change(Decidim::Geo::GeoConfig, :count)
            end

            it "broadcasts :invalid" do
              expect { command_update.call }.to broadcast(:invalid)
              expect { command_create.call }.to broadcast(:invalid)
            end
          end

          context "when the form is valid and updating an existing config" do
            before do
              allow(form).to receive(:invalid?).and_return(false)
              # Ensure no shapefile logic is triggered in this context
              allow(form).to receive(:decidim_geo_shapefiles_id).and_return(nil)

              existing_config
            end

            it "updates the geo_config with the correct attributes" do
              allow(existing_config).to receive(:update!).and_return(true)

              command_update.call

              expect(existing_config).to have_received(:update!).with(
                hash_including(
                  longitude: -46.6333,
                  latitude: -23.5505,
                  zoom: 12,
                  tile: "https://example.com/tiles",
                  esri_tile_enabled: true,
                  maptiler_api_key: "secret_key",
                  maptiler_style_id: "style_123",
                  only_assemblies: false,
                  only_processes: true,
                  focus_zoom_level: 15,
                  default_geoencoded_filter: "no_force_geoencoded",
                  decidim_organization_id: organization.id,
                  decidim_geo_shapefiles_id: nil
                )
              )
            end

            it "does not create a new record" do
              expect { command_update.call }.not_to change(Decidim::Geo::GeoConfig, :count)
            end

            it "broadcasts :ok" do
              expect { command_update.call }.to broadcast(:ok)
            end
          end

          context "when the form is valid and creating a new config (geo_config is nil)" do
            before do
              allow(form).to receive(:invalid?).and_return(false)
              allow(form).to receive(:decidim_geo_shapefiles_id).and_return(nil)
            end

            it "creates a new GeoConfig with the correct attributes" do
              allow(Decidim::Geo::GeoConfig).to receive(:create!).and_return(instance_double(Decidim::Geo::GeoConfig))

              command_create.call

              expect(Decidim::Geo::GeoConfig).to have_received(:create!).with(
                hash_including(
                  longitude: -46.6333,
                  latitude: -23.5505,
                  zoom: 12,
                  decidim_organization_id: organization.id
                )
              )
            end

            it "broadcasts :ok" do
              expect { command_create.call }.to broadcast(:ok)
            end
          end

          context "when a shapefile ID is provided in the form" do
            let(:shapefile) { create(:shapefile, organization:) }

            let(:form_with_shapefile) do
              double(
                "Form",
                longitude: -46.6333,
                latitude: -23.5505,
                zoom: 12,
                tile: "https://example.com/tiles",
                esri_tile_enabled: false,
                maptiler_api_key: "",
                maptiler_style_id: "",
                only_assemblies: false,
                only_processes: false,
                focus_zoom_level: 10,
                default_geoencoded_filter: "force_geoencoded",
                organization: organization,
                decidim_geo_shapefiles_id: shapefile.id,
                taxonomy_id: 999,
                invalid?: false
              )
            end

            let(:command_with_shapefile) { described_class.new(existing_config, form_with_shapefile) }

            before do
              allow(form_with_shapefile).to receive(:invalid?).and_return(false)
              # Stub the finder to return the existing shapefile
              allow(Decidim::Geo::Shapefile).to receive(:find_by).with(id: shapefile.id).and_return(shapefile)
            end

            it "updates the associated shapefile with the taxonomy ID" do
              allow(shapefile).to receive(:decidim_taxonomies_id=)
              allow(shapefile).to receive(:save!).and_return(true)

              command_with_shapefile.call

              expect(shapefile).to have_received(:decidim_taxonomies_id=).with(999)
              expect(shapefile).to have_received(:save!)
            end

            it "broadcasts :ok after updating both config and shapefile" do
              allow(shapefile).to receive(:decidim_taxonomies_id=)
              allow(shapefile).to receive(:save!)

              expect { command_with_shapefile.call }.to broadcast(:ok)
            end
          end

          context "when the shapefile ID is provided but the shapefile does not exist" do
            before do
              allow(form).to receive(:invalid?).and_return(false)
              allow(form).to receive(:decidim_geo_shapefiles_id).and_return(9999)
              # Return nil when the shapefile is not found
              allow(Decidim::Geo::Shapefile).to receive(:find_by).with(id: 9999).and_return(nil)
              allow(existing_config).to receive(:update!).and_return(true)
            end

            it "does not crash and completes the config update" do
              # The command should handle the nil shapefile gracefully (due to 'return unless shapefile')
              expect { command_update.call }.to broadcast(:ok)
            end
          end
        end
      end
    end
  end
end
