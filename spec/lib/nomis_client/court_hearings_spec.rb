# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::CourtHearings, with_nomis_client_authentication: true do
  describe '.get' do
    subject(:court_hearings) { described_class }

    let(:booking_id) { '1495077' }

    let(:responses) do
      [
        instance_double(
          'OAuth2::Response',
          body: page_one_response_body,
          parsed: JSON.parse(page_one_response_body),
          headers: page_one_headers,
          status: 200,
        ),
        instance_double(
          'OAuth2::Response',
          body: page_two_response_body,
          parsed: JSON.parse(page_two_response_body),
          headers: page_two_headers,
          status: 200,
        ),
      ]
    end

    let(:page_one_headers) do
      {
        'total-records' => total_records,
        'page-offset' => '0',
        'page-limit' => '2',
      }
    end

    let(:page_two_headers) do
      {
        'total-records' => '4',
        'page-offset' => '1',
        'page-limit' => '2',
      }
    end

    let(:page_one_response_body) { file_fixture('nomis_get_court_hearings_page_1_200.json').read }
    let(:page_two_response_body) { file_fixture('nomis_get_court_hearings_page_2_200.json').read }

    let(:total_records) { 2 }

    let(:start_date) { Date.today }
    let(:end_date) { Date.tomorrow }

    before do
      allow(token).to receive(:get).and_return(*responses)
      stub_const('NomisClient::Base::PAGE_LIMIT', 2)
    end

    it 'calls the NomisClient::Base.get with the correct path and params' do
      court_hearings.get(booking_id, start_date, end_date)

      expect(token).to have_received(:get).with(
        "/elite2api/api/bookings/1495077/court-hearings?fromDate=#{start_date.iso8601}&toDate=#{end_date.iso8601}",
        headers: { 'Page-Limit' => '20', 'Page-Offset' => '0' },
      )
    end

    context 'when there are more than one page of court_hearings to retrieve' do
      let(:total_records) { 4 }

      it 'calls the NomisClient::Base.get with the correct path and params' do
        court_hearings.get(booking_id)

        expect(token).to have_received(:get).twice
      end

      it 'paginates through court_hearings' do
        result = court_hearings.get(booking_id)

        expect(result.length).to eq(4)
      end
    end

    context 'when there is only one page of court_hearings to retrieve' do
      let(:total_records) { 2 }

      it 'calls the NomisClient::Base.get with the correct path and params' do
        court_hearings.get(booking_id, start_date, end_date)

        expect(token).to have_received(:get).once
      end

      it 'does not paginate through court_hearings' do
        result = court_hearings.get(booking_id)

        expect(result.length).to eq(2)
      end
    end
  end

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
