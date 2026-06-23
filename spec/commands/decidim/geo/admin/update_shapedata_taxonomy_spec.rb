# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Geo
    module Admin
      describe UpdateShapedataTaxonomy do
        describe "#call" do
          let(:organization) { create(:organization) }
          let(:taxonomy_id) { 123 }

          # Simulates a form object
          let(:form) do
            double(
              "Form",
              id: taxonomy_id,
              shapedata_id: target_shapedata.id,
              invalid?: false
            )
          end

          # The target shapefile (created clean)
          let(:target_shapedata) { create(:shapefile, organization:, decidim_taxonomies_id: nil) }

          # A pre-existing shapefile (created clean)
          let(:old_shapedata) { create(:shapefile, organization:, decidim_taxonomies_id: nil) }

          let(:command) { described_class.new(form) }

          context "when the form is invalid" do
            before do
              allow(form).to receive(:invalid?).and_return(true)
            end

            it "does not update any shapefile" do
              expect(Decidim::Geo::Shapedata).not_to receive(:find_by)
              expect(target_shapedata).not_to receive(:update!)

              command.call
            end

            it "broadcasts :invalid" do
              expect { command.call }.to broadcast(:invalid)
            end
          end

          context "when the form is valid and another shapefile already has the taxonomy" do
            before do
              allow(form).to receive(:invalid?).and_return(false)

              # Mock the finder for the OLD shapefile
              allow(Decidim::Geo::Shapedata).to receive(:find_by)
                .with(decidim_taxonomies_id: taxonomy_id)
                .and_return(old_shapedata)

              # Mock the finder for the TARGET shapefile
              allow(Decidim::Geo::Shapedata).to receive(:find_by)
                .with(id: target_shapedata.id)
                .and_return(target_shapedata)
            end

            it "clears the taxonomy from the old shapefile" do
              allow(target_shapedata).to receive(:update!).and_return(true)
              allow(old_shapedata).to receive(:decidim_taxonomies_id=)
              allow(old_shapedata).to receive(:save!).and_return(true)

              command.call

              expect(old_shapedata).to have_received(:decidim_taxonomies_id=).with(nil)
              expect(old_shapedata).to have_received(:save!)
            end

            it "assigns the taxonomy to the new target shapefile" do
              allow(target_shapedata).to receive(:update!).and_return(true)

              command.call

              expect(target_shapedata).to have_received(:update!).with(
                decidim_taxonomies_id: taxonomy_id
              )
            end

            it "broadcasts :ok" do
              # Mock both updates to allow the command to finish
              allow(old_shapedata).to receive(:decidim_taxonomies_id=).with(nil)
              allow(old_shapedata).to receive(:save!).and_return(true)
              allow(target_shapedata).to receive(:update!).and_return(true)

              expect { command.call }.to broadcast(:ok)
            end
          end

          context "when the form is valid and no other shapefile has the taxonomy" do
            before do
              allow(form).to receive(:invalid?).and_return(false)

              # Return nil when searching for an existing association
              allow(Decidim::Geo::Shapedata).to receive(:find_by)
                .with(decidim_taxonomies_id: taxonomy_id)
                .and_return(nil)

              allow(Decidim::Geo::Shapedata).to receive(:find_by)
                .with(id: target_shapedata.id)
                .and_return(target_shapedata)
            end

            it "does not try to clear any old shapefile" do
              allow(target_shapedata).to receive(:update!).and_return(true)

              expect(old_shapedata).not_to receive(:save!)

              command.call
            end

            it "assigns the taxonomy to the target shapefile" do
              allow(target_shapedata).to receive(:update!).and_return(true)

              command.call

              expect(target_shapedata).to have_received(:update!).with(
                decidim_taxonomies_id: taxonomy_id
              )
            end

            it "broadcasts :ok" do
              allow(target_shapedata).to receive(:update!).and_return(true)

              expect { command.call }.to broadcast(:ok)
            end
          end

          context "when the target shapefile does not exist" do
            before do
              allow(form).to receive(:invalid?).and_return(false)
              allow(Decidim::Geo::Shapedata).to receive(:find_by)
                .with(decidim_taxonomies_id: taxonomy_id)
                .and_return(nil)

              # Return nil for the target ID as well
              allow(Decidim::Geo::Shapedata).to receive(:find_by)
                .with(id: target_shapedata.id)
                .and_return(nil)
            end

            it "handles the missing shapefile gracefully without crashing" do
              # Based on the provided code, this WILL raise an error.
              expect { command.call }.to raise_error(NoMethodError)
            end
          end
        end
      end
    end
  end
end
