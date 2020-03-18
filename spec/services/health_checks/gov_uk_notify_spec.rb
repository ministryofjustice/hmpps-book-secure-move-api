# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HealthChecks::GovUkNotify do
  subject(:healthy?) { described_class.new.healthy? }

  let(:client) { class_double(Faraday, post: nil) }
  let(:healthy_response) {
    instance_double(Faraday::Response, success?: true, status: 200, body:
      '{
          "components": [
              {
                  "status": "operational",
                  "name": "API"
              },
              {
                  "status": "operational",
                  "name": "Email sending"
              }
          ]
      }')
  }
  let(:unhealthy_response) {
    instance_double(Faraday::Response, success?: true, status: 200, body:
      '{
          "components": [
              {
                  "status": "operational",
                  "name": "API"
              },
              {
                  "status": "broken",
                  "name": "Email sending"
              }
          ]
      }')
  }
  let(:offline_response) { instance_double(Faraday::Response, success?: false, status: 503) }

  before do
    allow(Faraday).to receive(:new).and_return(client)
    allow(Rails.logger).to receive(:warn)
    allow(Raven).to receive(:capture_message)
  end

  context 'when Gov.uk Notify is healthy' do
    before { allow(client).to receive(:get).and_return(healthy_response) }

    it { expect(healthy?).to be true }

    describe 'logging' do
      before { healthy? }

      it { expect(Rails.logger).not_to have_received(:warn) }
      it { expect(Raven).not_to have_received(:capture_message) }
    end
  end

  context 'when Gov.uk Notify is unhealthy' do
    before { allow(client).to receive(:get).and_return(unhealthy_response) }

    it { expect(healthy?).to be false }

    describe 'logging' do
      before { healthy? }

      it { expect(Rails.logger).to have_received(:warn).with('[GovUkNotify] service is unhealthy: {"API":true,"Email sending":false}') }
      it { expect(Raven).to have_received(:capture_message).with('[GovUkNotify] service is unhealthy', extra: { 'API' => true, 'Email sending' => false }, level: 'warning') }
    end
  end

  context 'when Gov.uk Notify is offline' do
    before { allow(client).to receive(:get).and_return(offline_response) }

    it { expect(healthy?).to be false }

    describe 'logging' do
      before { healthy? }

      it { expect(Rails.logger).to have_received(:warn).with('[GovUkNotify] service is unhealthy: {"response":503}') }
      it { expect(Raven).to have_received(:capture_message).with('[GovUkNotify] service is unhealthy', extra: { response: 503 }, level: 'warning') }
    end
  end

  context 'when an exception is raised' do
    before { allow(client).to receive(:get).and_raise(RuntimeError, 'Some unexpected error') }

    it { expect(healthy?).to be false }

    describe 'logging' do
      before { healthy? }

      it { expect(Rails.logger).to have_received(:warn).with('[GovUkNotify] service is unhealthy: {"error":"Some unexpected error"}') }
      it { expect(Raven).to have_received(:capture_message).with('[GovUkNotify] service is unhealthy', extra: { error: 'Some unexpected error' }, level: 'warning') }
    end
  end
end
