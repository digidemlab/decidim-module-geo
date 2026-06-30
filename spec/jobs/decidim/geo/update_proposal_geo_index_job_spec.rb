# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Geo
    describe UpdateProposalGeoIndexJob do
      subject { described_class }

      let(:job_instance) { described_class.new }
      let(:proposal) { create(:proposal) }
      let(:proposal_id) { proposal.id }
      let(:index_match) { build(:geo_index, resource_id: proposal_id, resource_type: "proposals") }

      before do
        allow(job_instance).to receive(:upsert_index).and_return(true)
        allow(job_instance).to receive(:remove_from_index?).and_return(false)
        allow(Decidim::Geo::Index).to receive(:find_by).and_return(index_match)
        allow(job_instance).to receive(:manifest_name).and_return("proposals")
        allow(job_instance).to receive(:resource_url).and_return("http://test.com")
        allow(job_instance).to receive(:image_url).and_return(nil)
        allow(job_instance).to receive(:title).and_return(proposal.title)
        allow(job_instance).to receive(:short_description).and_return(proposal.body)
        allow(job_instance).to receive(:description).and_return(proposal.body)
        allow(job_instance).to receive(:start_date).and_return(proposal.participatory_space.start_date)
        allow(job_instance).to receive(:end_date).and_return(proposal.participatory_space.end_date)
        allow(job_instance).to receive(:default_locale).and_return("en")
      end

      describe "#process" do
        context "when environment is production" do
          before { allow(Rails.env).to receive(:production?).and_return(true) }

          it "enqueues the job using perform_later" do
            expect(described_class).to receive(:perform_later).with(proposal_id)
            expect(described_class).not_to receive(:perform_now)
            described_class.process(proposal_id)
          end
        end

        context "when environment is not production (development/test)" do
          before { allow(Rails.env).to receive(:production?).and_return(false) }

          it "executes the job immediately using perform_now" do
            expect(described_class).to receive(:perform_now).with(proposal_id)
            expect(described_class).not_to receive(:perform_later)
            described_class.process(proposal_id)
          end
        end
      end

      describe "#perform" do
        let(:job_instance) { described_class.new }

        context "when proposal exists" do
          context "and should be synced (visible)" do
            before do
              allow(job_instance).to receive(:remove_from_index?).and_return(false)
            end

            it "calls sync_proposal" do
              allow(job_instance).to receive(:sync_proposal).and_return(true)
              job_instance.perform(proposal_id)
              expect(job_instance).to have_received(:sync_proposal)
            end

            it "sets the @resource instance variable" do
              job_instance.perform(proposal_id)
              expect(job_instance.instance_variable_get(:@resource)).to eq(proposal)
              expect(job_instance.instance_variable_get(:@resource_id)).to eq(proposal_id)
            end
          end

          context "and should be removed (not visible)" do
            before do
              allow(job_instance).to receive(:remove_from_index?).and_return(true)
            end

            it "calls remove_proposal" do
              expect(job_instance).to receive(:remove_proposal)
              expect(job_instance).not_to receive(:upsert_index)
              job_instance.perform(proposal_id)
            end
          end
        end

        context "when proposal does not exist" do
          let(:non_existent_id) { 999_999_999 }

          it "calls remove_proposal" do
            expect(job_instance).to receive(:remove_proposal)
            job_instance.perform(non_existent_id)
          end
        end

        context "when an error occurs during sync" do
          before do
            allow(job_instance).to receive(:remove_from_index?).and_return(false)
            allow(job_instance).to receive(:upsert_index).and_raise(StandardError, "Database connection failed")
            allow(Rails.logger).to receive(:warn).and_call_original
          end

          it "logs the error and returns false" do
            expect(Rails.logger).to receive(:warn).at_least(:once)
            result = job_instance.perform(proposal_id)
            expect(result).to be_falsey
          end
        end
      end

      describe "#remove_proposal" do
        let(:job_instance) { described_class.new }

        context "when an index entry exists" do
          it "finds and destroys the index entry" do
            expect(index_match).to receive(:destroy)
            job_instance.send(:remove_proposal)
          end
        end

        context "when no index entry exists" do
          before do
            allow(Decidim::Geo::Index).to receive(:find_by).and_return(nil)
          end

          it "does not raise an error" do
            expect { job_instance.send(:remove_proposal) }.not_to raise_error
          end
        end
      end

      describe "#proposal_status" do
        let(:job_instance) { described_class.new }

        context "when checking valid status values" do
          it "returns 'withdrawn' for a withdrawn proposal" do
            proposal = create(:proposal, :withdrawn) # Requer factory com trait :withdrawn
            job_instance.instance_variable_set(:@resource, proposal)

            status = job_instance.send(:proposal_status)

            expect(status).to eq("withdrawn")
          end

          it "returns the state token for a proposal with a state" do
            component = create(:proposal_component)
            state = create(:proposal_state, :accepted, component: component)

            proposal = create(:proposal, component: component)

            proposal.update!(proposal_state: state)
            proposal.reload

            job_instance.instance_variable_set(:@resource, proposal)

            status = job_instance.send(:proposal_status)

            expect(status).to eq(state.token)
          end

          # Teste 3: Proposta Sem Estado
          it "returns nil for a proposal without a state" do
            proposal = create(:proposal, proposal_state: nil)
            job_instance.instance_variable_set(:@resource, proposal)

            status = job_instance.send(:proposal_status)

            expect(status).to be_nil
          end

          # Teste 4: Verificação Genérica (O que você pediu)
          # Verifica se o retorno é sempre um dos valores possíveis do domínio
          it "returns only valid status values" do
            valid_statuses = ["open", "accepted", "rejected", "withdrawn", nil]

            # Cria uma proposta e verifica
            proposal = create(:proposal)
            job_instance.instance_variable_set(:@resource, proposal)

            result = job_instance.send(:proposal_status)

            # Garante que o resultado é um dos valores aceitáveis
            expect(valid_statuses).to include(result)
          end
        end
      end
    end
  end
end
