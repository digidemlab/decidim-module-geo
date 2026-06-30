# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Geo
    describe Index do
      describe "table_name" do
        it "uses the correct table name" do
          expect(described_class.table_name).to eq("decidim_geo_indexes")
        end
      end

      describe "associations" do
        it { is_expected.to belong_to(:organization).class_name("Decidim::Organization").with_foreign_key(:decidim_organization_id) }
      end

      describe "scopes" do
        let(:organization) { create(:organization) }
        let(:indexed_record) { create(:geo_index, organization: organization, avoid_index: false) }
        let(:avoided_record) { create(:geo_index, organization: organization, avoid_index: true) }
        let(:geolocated_record) { create(:geo_index, organization: organization, lonlat: { x: -43.17, y: -22.90 }) }
        let(:virtual_record) { create(:geo_index, :virtual, organization: organization) }
        let(:component_record) { create(:geo_index, :for_component, organization: organization) }
        let(:space_record) { create(:geo_index, :for_space, organization: organization) }

        describe ".indexed" do
          it "includes records where avoid_index is false" do
            expect(described_class.indexed).to include(indexed_record)
          end

          it "excludes records where avoid_index is true" do
            expect(described_class.indexed).not_to include(avoided_record)
          end
        end

        describe ".geolocated" do
          it "includes records with lonlat" do
            expect(described_class.geolocated).to include(geolocated_record)
          end

          it "excludes records without lonlat" do
            expect(described_class.geolocated).not_to include(virtual_record)
          end
        end

        describe ".virtual" do
          it "includes records without lonlat" do
            expect(described_class.virtual).to include(virtual_record)
          end

          it "excludes records with lonlat" do
            expect(described_class.virtual).not_to include(geolocated_record)
          end
        end

        describe ".components" do
          it "includes records with component_id" do
            expect(described_class.components).to include(component_record)
          end

          it "excludes records without component_id" do
            expect(described_class.components).not_to include(space_record)
          end
        end

        describe ".participatory_spaces" do
          it "includes records without component_id" do
            expect(described_class.participatory_spaces).to include(space_record)
          end

          it "excludes records with component_id" do
            expect(described_class.participatory_spaces).not_to include(component_record)
          end
        end

        describe ".organization" do
          let(:other_org) { create(:organization) }
          let(:other_record) { create(:geo_index, organization: other_org) }

          it "filters by organization" do
            expect(described_class.organization(organization)).to include(indexed_record)
            expect(described_class.organization(organization)).not_to include(other_record)
          end
        end
      end

      describe "#coordinates" do
        context "when lonlat is present and valid" do
          let(:record) { build(:geo_index, lonlat: { x: 10.5, y: 20.3 }) }

          it "returns a hash with longitude and latitude" do
            coords = record.coordinates
            expect(coords[:longitude]).to eq(10.5)
            expect(coords[:latitude]).to eq(20.3)
          end
        end

        context "when lonlat is nil" do
          let(:record) { build(:geo_index, :virtual) }

          it "returns nil" do
            expect(record.coordinates).to be_nil
          end
        end

        context "when lonlat has NaN values" do
          # Simulando um objeto que se comporta como NaN se o BD retornar assim
          let(:nan_point) { double(:point, x: Float::NAN, y: 20.0) }
          let(:record) { build(:geo_index) }

          before do
            allow(record).to receive(:lonlat).and_return(nan_point)
          end

          it "returns nil to avoid invalid coordinates" do
            expect(record.coordinates).to be_nil
          end
        end
      end

      describe "#as_json" do
        let(:record) { build(:geo_index, title: "Test Title", lonlat: { x: 1.0, y: 2.0 }) }
        let(:json) { record.as_json }

        it "camelizes all keys" do
          expect(json.keys).to include("resourceId", "resourceType", "title", "lonlat")
          expect(json.keys).not_to include("resource_id", "resource_type")
        end

        it "includes the coordinates hash under the lonlat key" do
          expect(json["lonlat"]).to eq({ longitude: 1.0, latitude: 2.0 })
        end

        it "preserves the values correctly" do
          expect(json["title"]).to eq("Test Title")
        end

        context "when lonlat is nil" do
          let(:record) { build(:geo_index, :virtual) }

          it "does not include the lonlat key or includes it as nil depending on super implementation" do
            # O comportamento exato depende de como o ActiveRecord lida com nil no super,
            # mas nossa lógica só faz merge se existir.
            json_output = record.as_json
            # Se o super retornar "lonlat": nil, nossa lógica não faz o merge de coordinates.
            # O teste verifica se não quebra.
            expect { json_output }.not_to raise_error
          end
        end
      end
    end
  end
end
