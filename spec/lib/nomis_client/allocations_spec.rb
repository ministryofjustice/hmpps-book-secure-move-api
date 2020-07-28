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
        .with('/elite2api/api/bookings/1111/prison-to-prison', body: '{}', headers: { Accept: 'application/json', 'Content-Type': 'application/json' })
    end

    context 'when Nomis returns an error' do
      before do
        allow(oauth2_response).to receive(:error=)
        allow(token).to receive(:post).and_raise(OAuth2::Error.new(oauth2_response))
      end

      let(:response_status) { 500 }

      let(:raven_args) do
        [
          'Allocations::CreateInNomis Error!',
          extra: {
            body_params: {},
            route: '/bookings/1111/prison-to-prison',
            nomis_response: { body: '{}', status: 500 },
          },
          level: 'error',
        ]
      end

      it 'pushes an error warning to Sentry' do
        allow(Raven).to receive(:capture_message)

        prison_transfer_post

        expect(Raven).to have_received(:capture_message).with(*raven_args)
      end
    end
  end
end
