# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Geo
    module Admin
      describe GeoConfigsController do
        routes { Decidim::Geo::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, organization:) }
        let(:geo_config) { create(:geo_config, organization:) }

        before do
          request.env["decidim.current_organization"] = organization
          login_as user, scope: :user
          seed_geo_toggle(organization, enabled: true)
          allow(Decidim::Map).to receive(:available?).and_return(true)
          allow(Decidim::Geo::GeoConfig).to receive(:geo_config_default)
            .with(organization)
            .and_return(geo_config)
        end

        describe "GET #index" do
          it "redirects to the show action" do
            get geo_configs_path
            expect(response).to redirect_to(geo_configs_path(geo_config.id))
          end
        end

        describe "GET #show" do
          context "when the organization is not geo-enabled" do
            before do
              seed_geo_toggle(organization, enabled: false)
            end

            it "raises ActiveRecord::RecordNotFound" do
              get geo_configs_path(geo_config.id)
              expect(response).to raise_error(ActiveRecord::RecordNotFound)
            end
          end

          context "when the organization is geo-enabled" do
            let(:shapefile) { create(:shapefile, organization:, decidim_taxonomies_id: nil) }
            let(:taxonomy_id) { 999 }
            let(:taxonomy_mock) { double("Taxonomy") }

            before do
              seed_geo_toggle(organization, enabled: true)
              allow(Decidim::Geo::GeoConfig).to receive(:geo_config_default)
                .with(organization)
                .and_return(geo_config)

              allow(Decidim::Geo::Shapefile).to receive(:find_by)
                .with(id: geo_config.decidim_geo_shapefiles_id)
                .and_return(shapefile)

              allow(shapefile).to receive(:decidim_taxonomies_id).and_return(taxonomy_id)
              allow(shapefile).to receive(:taxonomy).and_return(taxonomy_mock)
            end

            it "initializes the form from the model" do
              get :show, params: { id: geo_config.id }

              expect(response).to be_successful
              expect(assigns(:form)).to be_present
            end

            it "assigns the taxonomy_id to the form if shapefile exists" do
              get :show, params: { id: geo_config.id }

              expect(assigns(:form).taxonomy_id).to eq(taxonomy_id)
            end
          end
        end

        describe "POST #create" do
          let(:valid_params) do
            {
              geo_config: {
                longitude: -46.6333,
                latitude: -23.5505,
                zoom: 12
              }
            }
          end

          it "delegates to the update action logic" do
            allow(Admin::UpdateGeoConfig).to receive(:call)
              .with(geo_config, instance_of(Decidim::Geo::Admin::GeoConfigForm))
              .and_yield(:ok, nil)

            post geo_configs_path, params: valid_params

            expect(response).to redirect_to(geo_configs_path(geo_config.id))
            expect(flash[:notice]).to be_present
          end
        end

        describe "PUT #update", type: :routing do
          let(:valid_params) do
            {
              geo_config: {
                longitude: -46.6333,
                latitude: -23.5505,
                zoom: 12
              }
            }
          end

          let(:invalid_params) do
            {
              geo_config: {
                longitude: nil,
                latitude: nil,
                zoom: nil
              }
            }
          end

          context "when the command succeeds" do
            before do
              allow(Admin::UpdateGeoConfig).to receive(:call)
                .with(geo_config, instance_of(Decidim::Geo::Admin::GeoConfigForm))
                .and_yield(:ok, nil)
            end

            it "updates the config and redirects with notice" do
              put :update, params: valid_params

              expect(response).to redirect_to(action: :show, id: geo_config.id)
              expect(flash[:notice]).to eq(I18n.t("geo_configs.actions.update.success", scope: "decidim.geo.admin"))
            end
          end

          context "when the command fails (invalid)" do
            let(:form_double) { double("Form", errors: double(full_messages: ["Longitude can't be blank"])) }

            before do
              allow(Admin::UpdateGeoConfig).to receive(:call)
                .with(geo_config, instance_of(Decidim::Geo::Admin::GeoConfigForm))
                .and_yield(:invalid, nil)

              allow(controller).to receive(:form).and_return(form_double)
            end

            it "renders the show action with alert" do
              put :update, params: invalid_params

              expect(response).to render_template(:show)
              expect(flash.now[:alert]).to include("Longitude can't be blank")
            end
          end
        end

        describe "helper methods" do
          context "when shapefile is nil" do
            before do
              allow(Decidim::Geo::Shapefile).to receive(:find_by).and_return(nil)
              allow(Decidim::Geo::GeoConfig).to receive(:geo_config_default).and_return(geo_config)
            end

            it "returns false for has_taxonomy?" do
              # Usa be_falsey para aceitar nil ou false
              expect(controller.send(:has_taxonomy?)).to be_falsey
            end

            it "returns false for has_shapedata?" do
              expect(controller.send(:has_shapedata?)).to be_falsey
            end
          end

          context "when shapefile exists but has no taxonomy" do
            let(:shapefile_no_tax) { create(:shapefile, organization:, decidim_taxonomies_id: nil) }

            before do
              allow(Decidim::Geo::Shapefile).to receive(:find_by).and_return(shapefile_no_tax)
              allow(shapefile_no_tax).to receive(:taxonomy).and_return(nil)
              allow(Decidim::Geo::GeoConfig).to receive(:geo_config_default).and_return(geo_config)
            end

            it "returns false for has_taxonomy?" do
              expect(controller.send(:has_taxonomy?)).to be_falsey
            end

            it "returns false for has_shapedata?" do
              expect(controller.send(:has_shapedata?)).to be_falsey
            end
          end

          context "when shapefile has a taxonomy with shapedata children" do
            let(:shapefile_with_tax) { create(:shapefile, organization:, decidim_taxonomies_id: nil) }
            let(:child_node) { double("Node", shapedata: "present_data") }
            let(:taxonomy) { double("Taxonomy", children: [child_node]) }

            before do
              allow(Decidim::Geo::Shapefile).to receive(:find_by).and_return(shapefile_with_tax)
              allow(shapefile_with_tax).to receive(:taxonomy).and_return(taxonomy)
              allow(Decidim::Geo::GeoConfig).to receive(:geo_config_default).and_return(geo_config)
            end

            it "returns true for has_taxonomy?" do
              expect(controller.send(:has_taxonomy?)).to be_truthy
            end

            it "returns true for has_shapedata?" do
              expect(controller.send(:has_shapedata?)).to be_truthy
            end
          end

          context "when shapefile has a taxonomy but NO shapedata children" do
            let(:shapefile_with_tax) { create(:shapefile, organization:, decidim_taxonomies_id: nil) }
            let(:child_node_empty) { double("Node", shapedata: nil) }
            let(:taxonomy) { double("Taxonomy", children: [child_node_empty]) }

            before do
              allow(Decidim::Geo::Shapefile).to receive(:find_by).and_return(shapefile_with_tax)
              allow(shapefile_with_tax).to receive(:taxonomy).and_return(taxonomy)
              allow(Decidim::Geo::GeoConfig).to receive(:geo_config_default).and_return(geo_config)
            end

            it "returns true for has_taxonomy?" do
              expect(controller.send(:has_taxonomy?)).to be_truthy
            end

            it "returns false for has_shapedata?" do
              expect(controller.send(:has_shapedata?)).to be_falsey
            end
          end
        end
      end
    end
  end
end
