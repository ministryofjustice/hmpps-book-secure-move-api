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

    let(:file_params) do
      {
        confirm_email_before_download: nil,
        file: Base64.strict_encode64('csv'),
        is_csv: true,
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

      describe 'govuk_notify_personalisation' do
        subject(:govuk_notify_personalisation) { mail.govuk_notify_personalisation }

        it { is_expected.to include('report-title': 'Person Escort Record Quality') }
        it { is_expected.to include('report-description': '2020-01-01 - 2021-01-01') }
        it { is_expected.to include('report-file': file_params) }
      end
    end
  end
end
