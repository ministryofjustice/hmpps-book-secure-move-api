# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportMailer, type: :mailer do
  around do |example|
    ClimateControl.modify GOVUK_NOTIFY_REPORT_TEMPLATE_ID: 'abc' do
      example.run
    end
  end

  describe '#person_escort_record_quality' do
    subject(:mail) do
      described_class.with(
        recipients:,
        start_date:,
        end_date:,
      ).person_escort_record_quality
    end

    let(:recipients) { ['test@example.com'] }
    let(:start_date) { Date.new(2020, 1, 1) }
    let(:end_date) { nil }
    let(:filename) { 'per_quality_report_2020-01-01.csv' }
    let(:file_params) do
      {
        confirm_email_before_download: nil,
        file: Base64.strict_encode64('csv'),
        filename:,
        retention_period: nil,
      }
    end

    before do
      allow(Reports::PersonEscortRecordQuality).to receive(:call).and_return('csv')
    end

    it 'sends the email to the recipients' do
      expect(mail.to).to match_array('test@example.com')
    end

    it 'sets the govuk_notify_template' do
      expect(mail.govuk_notify_template).to eql('abc')
    end

    describe 'govuk_notify_personalisation' do
      subject(:govuk_notify_personalisation) { mail.govuk_notify_personalisation }

      it { is_expected.to include('report-title': 'Person Escort Record Quality') }
      it { is_expected.to include('report-description': '2020-01-01 - ') }
      it { is_expected.to include('report-file': file_params) }
    end

    context 'with an end date' do
      let(:end_date) { Date.new(2021, 1, 1) }
      let(:filename) { 'per_quality_report_2020-01-01_to_2021-01-01.csv' }

      describe 'govuk_notify_personalisation' do
        subject(:govuk_notify_personalisation) { mail.govuk_notify_personalisation }

        it { is_expected.to include('report-title': 'Person Escort Record Quality') }
        it { is_expected.to include('report-description': '2020-01-01 - 2021-01-01') }
        it { is_expected.to include('report-file': file_params) }
      end
    end
  end

  describe '#moves_export' do
    subject(:mail) do
      described_class.with(
        recipient_email: 'user@example.com',
        moves: instance_double(ActiveRecord::Relation),
      ).moves_export
    end

    let(:csv_tempfile) { instance_double(Tempfile, path: '/tmp/test.csv', closed?: false) }

    before do
      moves_exporter = instance_double(Moves::Exporter, call: csv_tempfile)
      allow(Moves::Exporter).to receive(:new).and_return(moves_exporter)
      allow(csv_tempfile).to receive(:rewind)
      allow(csv_tempfile).to receive(:read).and_return('csv_content')
      allow(csv_tempfile).to receive(:close)
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:unlink)
      allow(Notifications).to receive(:prepare_upload)
    end

    describe 'to' do
      it { expect(mail.to).to eq(['user@example.com']) }
    end

    describe 'govuk_notify_template' do
      it { expect(mail.govuk_notify_template).to eq('abc') }
    end

    describe 'govuk_notify_personalisation' do
      subject(:govuk_notify_personalisation) { mail.govuk_notify_personalisation }

      before do
        allow(Time).to receive(:current).and_return(Time.zone.parse('2025-06-12 14:30:00'))
      end

      it { is_expected.to include('report-title': 'Moves Export') }
      it { is_expected.to include('report-description': 'CSV export generated on 12/06/2025 at 14:30') }
    end

    describe 'tempfile cleanup' do
      it 'closes and unlinks the tempfile' do
        mail.to # Force the mail to be built
        expect(csv_tempfile).to have_received(:close)
        expect(File).to have_received(:unlink).with('/tmp/test.csv')
      end
    end
  end
end
