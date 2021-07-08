# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Allocations, with_nomis_client_authentication: true do
  describe '.post' do
    subject(:prison_transfer_post) do
      described_class.post(booking_id: booking_id, body_params: {})
    end

    let(:booking_id) { 1111 }
    let(:response_status) { 201 }
    let(:response_body) { '{}' }

    it 'creates prison-to-prison transfer in Nomis' do
      prison_transfer_post

      expect(token)
        .to have_received(:post)
        .with('/api/bookings/1111/prison-to-prison', body: '{}', headers: { Accept: 'application/json', 'Content-Type': 'application/json' })
    end

    context 'when Nomis returns an error' do
      before do
        allow(oauth2_response).to receive(:error=)
        allow(token).to receive(:post).and_raise(OAuth2::Error.new(oauth2_response))
      end

      let(:response_status) { 500 }

      include_examples 'captures a message in Sentry' do
        let(:sentry_message) { 'Allocations::CreateInNomis Error!' }
        let(:sentry_options) do
          {
            extra: {
              body_params: {},
              route: '/bookings/1111/prison-to-prison',
              nomis_response: { body: '{}', status: 500 },
            },
            level: 'error',
          }
        end
      end
    end
  end

  describe '.put' do
    subject(:prison_transfer_put) do
      described_class.put(booking_id: booking_id, event_id: event_id, body_params: {})
    end

    let(:booking_id) { 1111 }
    let(:event_id) { 2222 }
    let(:response_status) { 201 }
    let(:response_body) { '{}' }

    it 'removes prison-to-prison transfer from Nomis' do
      prison_transfer_put

      expect(token)
        .to have_received(:put)
        .with('/api/bookings/1111/prison-to-prison/2222/cancel', body: '{}', headers: { Accept: 'application/json', 'Content-Type': 'application/json' })
    end

    context 'when Nomis returns an error' do
      before do
        allow(oauth2_response).to receive(:error=)
        allow(token).to receive(:put).and_raise(OAuth2::Error.new(oauth2_response))
      end

      let(:response_status) { 500 }

      include_examples 'captures a message in Sentry' do
        let(:sentry_message) { 'Allocations::RemoveFromNomis Error!' }
        let(:sentry_options) do
          {
            extra: {
              body_params: {},
              route: '/bookings/1111/prison-to-prison/2222/cancel',
              nomis_response: { body: '{}', status: 500 },
            },
            level: 'error',
          }
        end
      end
    end
  end
end
