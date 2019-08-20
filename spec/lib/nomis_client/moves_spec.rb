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

    context 'when in test mode', with_nomis_client_test_mode: true do
      around do |example|
        Timecop.freeze(now)
        example.run
        Timecop.return
      end

      let(:nomis_agency_id) { 'LEI' }
      let(:expected_file_name) { "#{NomisClient::Base::FIXTURE_DIRECTORY}/moves-#{offset}-#{nomis_agency_id}.json.erb" }
      let(:erb_test_fixture) do
        <<-ERB
        {
          "courtEvents": [
            {
              "offenderNo": "Y2489HY",
              "createDateTime": "<%= (Time.now + -1.days)&.iso8601 %>",
              "eventId": 436867017,
              "fromAgency": "WEI",
              "fromAgencyDescription": "WEALSTUN (HMP)",
              "toAgency": "LEI",
              "toAgencyDescription": "LEEDS (HMP)",
              "eventDate": "<%= (Time.now + -1.days)&.strftime('%Y-%m-%d') %>",
              "startTime": "<%= (Time.now + -1.days)&.strftime('%Y-%m-%d') + 'T' + '17:00:00' %>",
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
              "createDateTime": "<%= (Time.now + -1.days)&.iso8601 %>",
              "eventId": 436867018,
              "fromAgency": "OUT",
              "fromAgencyDescription": "OUTSIDE",
              "toAgency": "LEI",
              "toAgencyDescription": "LEEDS (HMP)",
              "eventDate": "<%= (Time.now + -1.days)&.strftime('%Y-%m-%d') %>",
              "startTime": "<%= (Time.now + -1.days)&.strftime('%Y-%m-%d') + 'T' + '17:00:00' %>",
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
        ERB
      end
      let(:now) { Time.local(2019, 8, 24, 12, 0, 0) }

      context 'when date is in the future' do
        let(:date) { Time.local(2019, 8, 25, 12, 0, 0) }
        let(:offset) { '1' }

        it 'uses the correct file name' do
          described_class.get(nomis_agency_ids: nomis_agency_ids, date: date)
          expect(File).to have_received(:read).with(expected_file_name)
        end

        it 'does not hit the real API' do
          described_class.get(nomis_agency_ids: nomis_agency_ids, date: date)
          expect(NomisClient::Base).not_to have_received(:get)
        end

        it 'returns the correct data' do
          expect(response.count).to be 4
        end

        it 'processes the ERB content (dates)' do
          expect(response['courtEvents'].first['startTime']).to eq '2019-08-23T17:00:00'
        end
      end

      context 'when date is today' do
        let(:date) { Time.local(2019, 8, 24, 17, 0, 0) }
        let(:offset) { '0' }

        it 'uses the correct file name' do
          described_class.get(nomis_agency_ids: nomis_agency_ids, date: date)
          expect(File).to have_received(:read).with(expected_file_name)
        end

        it 'does not hit the real API' do
          described_class.get(nomis_agency_ids: nomis_agency_ids, date: date)
          expect(NomisClient::Base).not_to have_received(:get)
        end
      end

      context 'when date is in the past' do
        let(:date) { Time.local(2019, 8, 22, 2, 0, 0) }
        let(:offset) { '-2' }

        it 'uses the correct file name' do
          described_class.get(nomis_agency_ids: nomis_agency_ids, date: date)
          expect(File).to have_received(:read).with(expected_file_name)
        end

        it 'does not hit the real API' do
          described_class.get(nomis_agency_ids: nomis_agency_ids, date: date)
          expect(NomisClient::Base).not_to have_received(:get)
        end
      end

      context 'when there is no fixture file for the given date' do
        let(:file_exists) { false }
        let(:date) { Time.local(2019, 8, 2, 2, 0, 0) }
        let(:offset) { '-22' }

        it 'uses the correct file name' do
          described_class.get(nomis_agency_ids: nomis_agency_ids, date: date)
          expect(File).to have_received(:exist?).with(expected_file_name)
        end

        it 'does not attempt to read the file' do
          described_class.get(nomis_agency_ids: nomis_agency_ids, date: date)
          expect(File).not_to have_received(:read).with(expected_file_name)
        end

        it 'does not hit the real API' do
          described_class.get(nomis_agency_ids: nomis_agency_ids, date: date)
          expect(NomisClient::Base).not_to have_received(:get)
        end

        it 'returns the correct data' do
          expect(response.count).to be 4
        end
      end
    end
  end
end
