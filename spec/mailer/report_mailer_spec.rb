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
        zip_file_path: '/tmp/test.zip',
        filename: 'moves_export_2025-06-12_14-30.zip',
      ).moves_export
    end

    before do
      allow(File).to receive(:read).with('/tmp/test.zip').and_return('zip_content')
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
      it { is_expected.to include('report-description': 'CSV export (zipped) generated on 12/06/2025 at 14:30') }
    end

    describe 'file handling' do
      it 'reads the ZIP file and prepares it for upload' do
        mail.to # Force the mail to be built
        expect(File).to have_received(:read).with('/tmp/test.zip')
        expect(Notifications).to have_received(:prepare_upload).with(
          an_instance_of(StringIO),
          filename: 'moves_export_2025-06-12_14-30.zip',
        )
      end
    end
  end
end
