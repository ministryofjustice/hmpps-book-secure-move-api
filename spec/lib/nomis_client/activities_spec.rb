# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Activities, with_nomis_client_authentication: true do
  describe '.get' do
    subject(:activities) { described_class }

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
        'Total-Records' => total_records,
        'Page-Offset' => '0',
        'Page-Limit' => '2',
      }
    end

    let(:page_two_headers) do
      {
        'Total-Records' => '4',
        'Page-Offset' => '1',
        'Page-Limit' => '2',
      }
    end

    let(:page_one_response_body) { file_fixture('nomis_get_activities_page_1_200.json').read }
    let(:page_two_response_body) { file_fixture('nomis_get_activities_page_2_200.json').read }

    let(:total_records) { 2 }

    let(:start_date) { Date.today }
    let(:end_date) { Date.tomorrow }

    before do
      allow(token).to receive(:get).and_return(*responses)
      stub_const('NomisClient::Base::PAGE_LIMIT', 2)
    end

    it 'calls the NomisClient::Base.get with the correct path and params' do
      activities.get(booking_id, start_date, end_date)

      expect(token).to have_received(:get).with(
        "/elite2api/api/bookings/1495077/activities?fromDate=#{start_date.iso8601}&toDate=#{end_date.iso8601}",
        headers: { 'Page-Limit' => '20', 'Page-Offset' => '0' },
      )
    end

    context 'when there are more than one page of activities to retrieve' do
      let(:total_records) { 4 }

      it 'calls the NomisClient::Base.get with the correct path and params' do
        activities.get(booking_id)

        expect(token).to have_received(:get).twice
      end

      it 'paginates through activities' do
        result = activities.get(booking_id)

        expect(result.length).to eq(4)
      end
    end

    context 'when there is only one page of activities to retrieve' do
      let(:total_records) { 2 }

      it 'calls the NomisClient::Base.get with the correct path and params' do
        activities.get(booking_id, start_date, end_date)

        expect(token).to have_received(:get).once
      end

      it 'does not paginate through activities' do
        result = activities.get(booking_id)

        expect(result.length).to eq(2)
      end
    end
  end
end
