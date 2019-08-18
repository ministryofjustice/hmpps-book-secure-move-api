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

    context 'when in test mode' do
      around do |example|
        Timecop.freeze(now)
        example.run
        Timecop.return
      end

      let(:now) { Time.local(2019, 8, 24, 12, 0, 0) }
      let(:date) { '2' }
      let(:nomis_agency_id) { 'LEI' }
      let(:expected_file_name) { "#{NomisClient::Base::FIXTURE_DIRECTORY}/moves-#{date}-#{nomis_agency_id}.json.erb" }
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

      before do
        allow(File).to receive(:read).and_return(erb_test_fixture)
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('NOMIS_TEST_MODE').and_return('true')
      end

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
  end

  describe '.anonymise' do
    let(:original) do
      {
        offenderNo: 'V6537TX',
        createDateTime: '2019-07-24T08:10:58',
        eventId: 123,
        fromAgency: 'WEI',
        fromAgencyDescription: 'WEALSTUN (HMP)',
        toAgency: 'LEI',
        toAgencyDescription: 'LEEDS (HMP)',
        eventDate: '2019-07-24',
        startTime: '2019-07-24T17:00:00',
        endTime: nil,
        eventClass: 'EXT_MOV',
        eventType: 'CRT',
        eventSubType: 'PR',
        eventStatus: 'COMP',
        judgeName: 'Bob',
        directionCode: 'IN',
        commentText: 'Comment about the move',
        bookingActiveFlag: true,
        bookingInOutStatus: 'IN'
      }.with_indifferent_access
    end
    let(:offender_number) { 'D1234VG' }
    let(:day_offset) { 1 }
    let(:anonymised) { described_class.anonymise(offender_number, day_offset, original) }

    it 'changes the offender number' do
      expect(anonymised[:offenderNo]).to eq offender_number
    end

    it 'resets commentText' do
      expect(anonymised[:commentText]).to be_nil
    end

    it 'resets judgeName' do
      expect(anonymised[:judgeName]).to be_nil
    end

    it 'sets eventDate to tomorrow' do
      expect(anonymised[:eventDate]).to eq "<%= (Time.now + 1.days)&.strftime('%Y-%m-%d') %>"
    end

    it 'sets createDateTime to tomorrow' do
      expect(anonymised[:createDateTime]).to eq '<%= (Time.now + 1.days)&.iso8601 %>'
    end

    it 'sets startTime to 17:00' do
      expect(anonymised[:startTime]).to eq "<%= (Time.now + 1.days)&.strftime('%Y-%m-%d') + 'T' + '17:00:00' %>"
    end
  end
end
