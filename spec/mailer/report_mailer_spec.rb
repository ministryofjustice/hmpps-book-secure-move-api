# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportMailer, type: :mailer do
  around do |example|
    ClimateControl.modify GOVUK_NOTIFY_REPORT_TEMPLATE_ID: 'abc' do
      example.run
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
