# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::CourtHearings, with_nomis_client_authentication: true do
  describe '.get' do
    subject(:court_hearings_get) { described_class.get(booking_id, start_date, end_date) }

    let(:booking_id) { '1495077' }
    let(:start_date) { Time.zone.today }
    let(:end_date) { Date.tomorrow }

    let(:response_body) { file_fixture('nomis/get_court_hearings_200.json').read }

    it 'calls the NomisClient::Base.get with the correct path and params' do
      court_hearings_get

      expect(token).to have_received(:get).with(
        "/api/bookings/1495077/court-hearings?fromDate=#{start_date.iso8601}&toDate=#{end_date.iso8601}",
        headers: { 'Page-Limit' => '1000' },
      )
    end

    it 'returns a parsed response body' do
      expect(court_hearings_get).to be_a(Hash)
    end
  end

  describe '.post' do
    subject(:court_hearing_post) do
      described_class.post(booking_id: booking_id, court_case_id: court_case_id, body_params: {})
    end

    let(:booking_id) { 1111 }
    let(:court_case_id) { 2222 }
    let(:response_status) { 201 }
    let(:response_body) { '{}' }

    it 'creates prison-to-court-hearing in Nomis ' do
      court_hearing_post

      expect(token)
        .to have_received(:post)
        .with('/api/bookings/1111/court-cases/2222/prison-to-court-hearings', body: '{}', headers: { Accept: 'application/json', 'Content-Type': 'application/json' })
    end

    context 'when Nomis returns an error' do
      before do
        allow(oauth2_response).to receive(:error=)
        allow(token).to receive(:post).and_raise(OAuth2::Error.new(oauth2_response))
      end

      let(:response_status) { 500 }
      let(:response_body) { { developerMessage: 'An error message.' }.to_json }

      include_examples 'captures a message in Sentry' do
        let(:sentry_message) { 'CourtHearings::CreateInNomis Error!' }
        let(:sentry_options) do
          {
            extra: {
              body_params: {},
              route: '/bookings/1111/court-cases/2222/prison-to-court-hearings',
              nomis_response_status: 500,
              nomis_response_body: '{"developerMessage":"An error message."}',
              nomis_response_message: 'An error message.',
            },
            level: 'error',
          }
        end
      end
    end
  end
end
