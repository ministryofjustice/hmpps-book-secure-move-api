# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MovesExportEmailWorker do
  describe '#perform' do
    subject(:worker) { described_class.new }

    let(:recipient_email) { 'user@example.com' }
    let(:move_ids) { [1, 2, 3] }
    let(:moves) { instance_double(ActiveRecord::Relation) }
    let(:report_mailer) { instance_double(ReportMailer) }
    let(:mail_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(Move).to receive(:includes).and_return(Move)
      allow(Move).to receive(:where).with(id: move_ids).and_return(moves)
      allow(ReportMailer).to receive(:with).and_return(report_mailer)
      allow(report_mailer).to receive(:moves_export).and_return(mail_delivery)
      allow(mail_delivery).to receive(:deliver_now)
    end

    it 'processes the export workflow correctly' do
      worker.perform(recipient_email, move_ids)

      expect(Move).to have_received(:includes).with(described_class::CSV_INCLUDES)
      expect(Move).to have_received(:where).with(id: move_ids)
      expect(ReportMailer).to have_received(:with).with(
        recipient_email: recipient_email,
        moves: moves,
      )
      expect(report_mailer).to have_received(:moves_export)
      expect(mail_delivery).to have_received(:deliver_now)
    end

    context 'when an error occurs' do
      before do
        allow(Move).to receive(:includes).and_raise(StandardError.new('Something went wrong'))
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error without re-raising' do
        expect {
          worker.perform(recipient_email, move_ids)
        }.not_to raise_error

        expect(Rails.logger).to have_received(:error).with(
          "MovesExportEmailWorker failed for email #{recipient_email}: Something went wrong",
        )
      end
    end

    context 'with empty move_ids array' do
      let(:move_ids) { [] }

      it 'handles empty move_ids gracefully' do
        worker.perform(recipient_email, move_ids)

        expect(Move).to have_received(:includes).with(described_class::CSV_INCLUDES)
        expect(Move).to have_received(:where).with(id: [])
        expect(ReportMailer).to have_received(:with).with(
          recipient_email: recipient_email,
          moves: moves,
        )
      end
    end

    context 'with single move_id' do
      let(:move_ids) { [42] }

      it 'handles single move ID correctly' do
        worker.perform(recipient_email, move_ids)

        expect(Move).to have_received(:where).with(id: [42])
      end
    end

    context 'when moves query returns empty result' do
      let(:empty_moves) { Move.none }

      before do
        allow(Move).to receive(:where).with(id: move_ids).and_return(empty_moves)
      end

      it 'still sends the email with empty moves collection' do
        worker.perform(recipient_email, move_ids)

        expect(ReportMailer).to have_received(:with).with(
          recipient_email: recipient_email,
          moves: empty_moves,
        )
        expect(mail_delivery).to have_received(:deliver_now)
      end
    end
  end

  it 'includes Sidekiq::Worker' do
    expect(described_class.included_modules).to include(Sidekiq::Worker)
  end

  describe 'CSV_INCLUDES constant' do
    it 'defines the correct includes for CSV export' do
      expected_includes = [:from_location, :to_location, :journeys, :profile, :supplier, { person: %i[gender ethnicity] }]
      expect(described_class::CSV_INCLUDES).to eq(expected_includes)
    end
  end
end
