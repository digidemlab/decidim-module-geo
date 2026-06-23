# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Geo
    module Admin
      describe CreateShapefile do
        describe "#call" do
          let(:organization) { create(:organization) }

          # Simulates a form object (can be a real instance or a double)
          let(:form) do
            double(
              "Form",
              title: "Test Shapefile",
              description: "A test description",
              shapefile: uploaded_file, # A fake file
              organization: organization,
              invalid?: false
            )
          end

          # Simulates an uploaded file (Rack::Test::UploadedFile or similar)
          let(:uploaded_file) do
            fixture_file_upload("spec/fixtures/files/test.shp", "application/x-shapefile")
          end

          let(:shapefile_loader) { instance_double(Decidim::Geo::ShapefileLoader) }
          let(:created_shapefile) { instance_double(Decidim::Geo::Shapefile, destroy: true) }

          subject { described_class.new(form).call }

          before do
            # Mock the ShapefileLoader to avoid real IO logic execution
            allow(Decidim::Geo::ShapefileLoader).to receive(:new).and_return(shapefile_loader)
          end

          context "when the form is valid" do
            before do
              allow(form).to receive(:invalid?).and_return(false)
              allow(shapefile_loader).to receive(:run!).and_return(true)

              # Mock the record creation to return our controlled double
              allow(Decidim::Geo::Shapefile).to receive(:create!).and_return(created_shapefile)
            end

            it "creates a new Shapefile" do
              subject

              expect(Decidim::Geo::Shapefile).to have_received(:create!).with(
                title: "Test Shapefile",
                description: "A test description",
                shapefile: uploaded_file,
                organization: organization
              )
            end

            it "initializes the ShapefileLoader with the created file" do
              subject

              expect(Decidim::Geo::ShapefileLoader).to have_received(:new).with(created_shapefile)
            end

            it "runs the loader" do
              subject

              expect(shapefile_loader).to have_received(:run!)
            end

            it "broadcasts :ok with the shapefile" do
              expect { subject }.to broadcast(:ok, created_shapefile)
            end
          end

          context "when the form is invalid" do
            before do
              allow(form).to receive(:invalid?).and_return(true)
            end

            it "does not create a Shapefile" do
              expect(Decidim::Geo::Shapefile).not_to receive(:create!)

              subject
            end

            it "does not initialize the loader" do
              expect(Decidim::Geo::ShapefileLoader).not_to receive(:new)

              subject
            end

            it "broadcasts :invalid" do
              expect { subject }.to broadcast(:invalid)
            end
          end

          context "when an error occurs during loading" do
            let(:error_message) { "Invalid projection" }

            before do
              allow(form).to receive(:invalid?).and_return(false)
              allow(Decidim::Geo::Shapefile).to receive(:create!).and_return(created_shapefile)
              allow(shapefile_loader).to receive(:run!).and_raise(StandardError.new(error_message))
              allow(created_shapefile).to receive(:destroy)
            end

            it "destroys the created shapefile to rollback" do
              expect(created_shapefile).to receive(:destroy)

              subject
            end

            it "broadcasts :invalid with the error message" do
              expect { subject }.to broadcast(:invalid, error_message)
            end
          end
        end
      end
    end
  end
end
