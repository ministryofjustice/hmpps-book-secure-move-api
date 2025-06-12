# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MovesExportEmailWorker do
  describe '#perform' do
    subject(:worker) { described_class.new }

    let(:recipient_email) { 'user@example.com' }
    let(:application_id) { 123 }
    let(:filter_params) { { from_location_id: 'location_1' } }
    let(:sort_params) { { created_at: 'desc' } }
    let(:active_record_relationships) { %i[from_location to_location journeys] }

    let(:application) { instance_double(Doorkeeper::Application) }
    let(:ability) { instance_double(Ability) }
    let(:moves_finder) { instance_double(Moves::Finder) }
    let(:moves_exporter) { instance_double(Moves::Exporter) }
    let(:report_mailer) { instance_double(ReportMailer) }
    let(:mail_delivery) { instance_double(ActionMailer::MessageDelivery) }

    let(:moves) { instance_double(ActiveRecord::Relation) }

    before do
      allow(Doorkeeper::Application).to receive(:find).with(application_id).and_return(application)
      allow(Ability).to receive(:new).with(application).and_return(ability)
      allow(Moves::Finder).to receive(:new).and_return(moves_finder)
      allow(moves_finder).to receive(:call).and_return(moves)
      allow(ReportMailer).to receive(:with).and_return(report_mailer)
      allow(report_mailer).to receive(:moves_export).and_return(mail_delivery)
      allow(mail_delivery).to receive(:deliver_now)
    end

    it 'finds the application by ID' do
      worker.perform(recipient_email, application_id, filter_params, sort_params, active_record_relationships)
      expect(Doorkeeper::Application).to have_received(:find).with(application_id)
    end

    it 'creates an ability object with the application' do
      worker.perform(recipient_email, application_id, filter_params, sort_params, active_record_relationships)
      expect(Ability).to have_received(:new).with(application)
    end

    it 'creates a moves finder with correct parameters' do
      worker.perform(recipient_email, application_id, filter_params, sort_params, active_record_relationships)
      expect(Moves::Finder).to have_received(:new).with(
        filter_params: filter_params,
        ability: ability,
        order_params: sort_params,
        active_record_relationships: active_record_relationships,
      )
    end

    it 'calls the moves finder to get the moves' do
      worker.perform(recipient_email, application_id, filter_params, sort_params, active_record_relationships)
      expect(moves_finder).to have_received(:call)
    end

    it 'sends the moves relation via ReportMailer with correct parameters' do
      worker.perform(recipient_email, application_id, filter_params, sort_params, active_record_relationships)
      expect(ReportMailer).to have_received(:with).with(
        recipient_email: recipient_email,
        moves: moves,
      )
      expect(report_mailer).to have_received(:moves_export)
      expect(mail_delivery).to have_received(:deliver_now)
    end

    context 'when an error occurs' do
      let(:error_message) { 'Something went wrong' }
      let(:standard_error) { StandardError.new(error_message) }

      before do
        allow(Doorkeeper::Application).to receive(:find).and_raise(standard_error)
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error with recipient email and error message' do
        expect {
          worker.perform(recipient_email, application_id, filter_params, sort_params, active_record_relationships)
        }.not_to raise_error

        expect(Rails.logger).to have_received(:error).with(
          "MovesExportEmailWorker failed for email #{recipient_email}: #{error_message}",
        )
      end

      it 'does not re-raise the error' do
        expect {
          worker.perform(recipient_email, application_id, filter_params, sort_params, active_record_relationships)
        }.not_to raise_error
      end

      it 'does not send email when error occurs' do
        worker.perform(recipient_email, application_id, filter_params, sort_params, active_record_relationships)
        expect(ReportMailer).not_to have_received(:with)
      end
    end

    context 'with different parameter combinations' do
      context 'with empty filter params' do
        let(:filter_params) { {} }

        it 'passes empty filter params to the finder' do
          worker.perform(recipient_email, application_id, filter_params, sort_params, active_record_relationships)
          expect(Moves::Finder).to have_received(:new).with(
            hash_including(filter_params: {}),
          )
        end
      end

      context 'with empty sort params' do
        let(:sort_params) { {} }

        it 'passes empty sort params to the finder' do
          worker.perform(recipient_email, application_id, filter_params, sort_params, active_record_relationships)
          expect(Moves::Finder).to have_received(:new).with(
            hash_including(order_params: {}),
          )
        end
      end

      context 'with complex active record relationships' do
        let(:active_record_relationships) do
          [:from_location, :to_location, :journeys, :profile, :supplier, { person: %i[gender ethnicity] }]
        end

        it 'passes the complex relationships to the finder' do
          worker.perform(recipient_email, application_id, filter_params, sort_params, active_record_relationships)
          expect(Moves::Finder).to have_received(:new).with(
            hash_including(active_record_relationships: active_record_relationships),
          )
        end
      end
    end

    context 'when different components fail' do
      context 'when Moves::Finder fails' do
        before do
          allow(moves_finder).to receive(:call).and_raise(StandardError.new('Finder error'))
          allow(Rails.logger).to receive(:error)
        end

        it 'logs the error and does not send email' do
          worker.perform(recipient_email, application_id, filter_params, sort_params, active_record_relationships)
          expect(Rails.logger).to have_received(:error).with(
            "MovesExportEmailWorker failed for email #{recipient_email}: Finder error",
          )
          expect(ReportMailer).not_to have_received(:with)
        end
      end

      context 'when ReportMailer fails' do
        before do
          allow(mail_delivery).to receive(:deliver_now).and_raise(StandardError.new('Mailer error'))
          allow(Rails.logger).to receive(:error)
        end

        it 'logs the error' do
          worker.perform(recipient_email, application_id, filter_params, sort_params, active_record_relationships)
          expect(Rails.logger).to have_received(:error).with(
            "MovesExportEmailWorker failed for email #{recipient_email}: Mailer error",
          )
        end
      end
    end
  end

  describe 'Sidekiq worker inclusion' do
    it 'includes Sidekiq::Worker' do
      expect(described_class.included_modules).to include(Sidekiq::Worker)
    end
  end
end
