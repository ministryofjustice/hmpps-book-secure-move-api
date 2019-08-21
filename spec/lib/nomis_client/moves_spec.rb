# frozen_string_literal: true

require 'rails_helper'
require 'dotenv/load'

RSpec.describe NomisClient::Moves do
  describe '.get' do
    let(:date) { DateTime.civil(2019, 7, 8, 12, 23, 45) }
    let(:nomis_agency_ids) { 'LEI' }
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
    let(:response) { described_class.get(nomis_agency_ids: nomis_agency_ids, date: date) }
    let(:params) do
      {
        agencyId: 'LEI',
        courtEvents: true,
        fromDateTime: '2019-07-08T00:00:00',
        toDateTime: '2019-07-09T00:00:00',
        movements: true,
        releaseEvents: true,
        transferEvents: true
      }
    end

    before do
      allow(NomisClient::Base).to(
        receive(:get)
        .with(
          '/movements/transfers',
          params: params,
          headers: { 'Page-Limit' => '1000' }
        )
        .and_return(nomis_response)
      )
    end

    it 'has the correct number of results' do
      expect(response.count).to be 4
    end
  end
end
