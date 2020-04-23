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
        'total-records' => '4',
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

    let(:page_one_response_body) { file_fixture('nomis_get_activities_page_1_200.json').read }
    let(:page_two_response_body) { file_fixture('nomis_get_activities_page_2_200.json').read }

    before do
      allow(token).to receive(:get).and_return(*responses)
    end

    it 'calls the NomisClient::Base.get with the correct path and params' do
      activities.get(booking_id)

      expected_path = "/bookings/#{booking_id}/activities?start_date=#{start_date.iso8601}&end_date=#{end_date.iso8601}"

      expect(token).to have received(:get).with(expected_path)
    end

    context 'when there are more than one page of activities to retrieve' do
      it 'paginates through activities' do
      end
    end

    context 'when there is only one page of activities to retrieve' do
      it 'does not paginate through activities' do
      end
    end
  end
end
