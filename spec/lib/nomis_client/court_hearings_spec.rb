# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::CourtHearing, with_nomis_client_authentication: true do
  describe '.post' do
    subject(:court_hearing_post) {
      described_class.post(booking_id: booking_id, court_case_id: court_case_id, body_params: {})
    }

    let(:booking_id) { 1111 }
    let(:court_case_id) { 2222 }
    let(:response_status) { 201 }
    let(:response_body) { '{}' }

    let(:raven_args) do
      [
        'CourtHearings:CreateInNomis success!',
        extra: {
          body_params: {},
          court_cases_route: '/bookings/1111/court-cases/2222/prison-to-court-hearings',
          nomis_response: { body: '{}', status: 201 },
        },
        level: 'warning',
      ]
    end

    it 'creates prison-to-court-hearing in Nomis ' do
      court_hearing_post

      expect(token)
        .to have_received(:post)
        .with('/elite2api/api/bookings/1111/court-cases/2222/prison-to-court-hearings', body: '{}', headers: { Accept: 'application/json', 'Content-Type': 'application/json' })
    end

    it 'pushes a success warning to Sentry' do
      allow(Raven).to receive(:capture_message)

      court_hearing_post

      expect(Raven).to have_received(:capture_message).with(*raven_args)
    end

    context 'when Nomis returns an error' do
      before do
        allow(oauth2_response).to receive(:error=)
        allow(token).to receive(:post).and_raise(OAuth2::Error.new(oauth2_response))
      end

      let(:response_status) { 500 }

      let(:raven_args) do
        [
          'CourtHearings:CreateInNomis Error!',
          extra: {
            body_params: {},
            court_cases_route: '/bookings/1111/court-cases/2222/prison-to-court-hearings',
            nomis_response: { body: '{}', status: 500 },
          },
          level: 'warning',
        ]
      end

      it 'pushes an error warning to Sentry' do
        allow(Raven).to receive(:capture_message)

        court_hearing_post

        expect(Raven).to have_received(:capture_message).with(*raven_args)
      end
    end
  end
end
