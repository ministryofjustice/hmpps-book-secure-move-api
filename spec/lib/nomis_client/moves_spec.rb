# frozen_string_literal: true

require 'rails_helper'
require 'dotenv/load'

RSpec.describe NomisClient::Moves do
  describe '.get_response' do
    let(:date) { DateTime.civil(2019, 7, 8, 12, 23, 45).to_date }
    let(:nomis_agency_id) { 'LEI' }
    let(:json_response) do
      <<-JSON
      {
        "courtEvents": [
          {
            "offenderNo": "Y2489HY",
            "createDateTime": "2019-08-14T17:20:29",
            "eventId": 436867017,
            "fromAgency": "WEI",
            "fromAgencyDescription": "WEALSTUN (HMP)",
            "toAgency": "LEI",
            "toAgencyDescription": "LEEDS (HMP)",
            "eventDate": "2019-08-14",
            "startTime": "2019-08-14T17:00:00",
            "endTime": null,
            "eventClass": "EXT_MOV",
            "eventType": "CRT",
            "eventSubType": "PS",
            "eventStatus": "COMP",
            "judgeName": null,
            "directionCode": "IN",
            "commentText": null,
            "bookingActiveFlag": true,
            "bookingInOutStatus": "IN"
          },
          {
            "offenderNo": "K2186XE",
            "createDateTime": "2019-08-14T13:42:30",
            "eventId": 436867018,
            "fromAgency": "OUT",
            "fromAgencyDescription": "OUTSIDE",
            "toAgency": "LEI",
            "toAgencyDescription": "LEEDS (HMP)",
            "eventDate": "2019-08-14",
            "startTime": "2019-08-14T17:00:00",
            "endTime": null,
            "eventClass": "COMM",
            "eventType": "CRT",
            "eventSubType": "PR",
            "eventStatus": "EXP",
            "judgeName": null,
            "directionCode": "IN",
            "commentText": null,
            "bookingActiveFlag": false,
            "bookingInOutStatus": "OUT"
          }
        ],
        "transferEvents": [],
        "releaseEvents": [],
        "movements": []
      }
      JSON
    end
    let(:nomis_response) { instance_double('response', parsed: JSON.parse(json_response)) }
    let(:response) { described_class.get_response(nomis_agency_id: nomis_agency_id, date: date) }
    let(:params) do
      {
        agencyId: 'LEI',
        courtEvents: true,
        fromDateTime: '2019-07-08T00:00:00',
        toDateTime: '2019-07-09T00:00:00',
        movements: false,
        releaseEvents: false,
        transferEvents: false
      }
    end

    before do
      allow(NomisClient::Base).to(
        receive(:get)
        .with(
          '/movements/transfers',
          params: params,
          headers: { 'Page-Limit' => '500' }
        )
        .and_return(nomis_response)
      )
    end

    it 'has the correct number of results' do
      expect(response.count).to be 4
    end
  end

  describe '.get', with_nomis_client_authentication: true do
    let(:nomis_agency_id) { 'BXI' }
    let(:date) { Date.parse('2019-08-19') }
    let(:response) { described_class.get(nomis_agency_id, date) }
    let(:client_response) do
      [
        {
          person_nomis_prison_number: 'G3239GV',
          from_location_nomis_agency_id: 'BXI',
          to_location_nomis_agency_id: 'BXI',
          date: '2019-08-19',
          time_due: '17:00:00',
          nomis_event_id: 468_536_961
        },
        {
          person_nomis_prison_number: 'G7157AB',
          from_location_nomis_agency_id: 'BXI',
          to_location_nomis_agency_id: 'WDGRCC',
          date: '2019-08-19',
          time_due: '09:00:00',
          nomis_event_id: 487_463_210
        }
      ]
    end

    context 'when results are present' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis_get_moves_200.json').read }

      it 'returns the correct moves data' do
        expect(response).to eq client_response
      end
    end
  end
end
