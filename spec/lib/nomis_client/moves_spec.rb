# frozen_string_literal: true

require 'rails_helper'
require 'dotenv/load'

RSpec.describe NomisClient::Moves do
  describe '.get' do
    let(:date) { DateTime.civil(2019, 7, 8, 12, 23, 45) }
    let(:nomis_agency_ids) { 'LEI' }
    let(:response) { described_class.get(nomis_agency_ids: nomis_agency_ids, date: date) }

    # it 'has the correct number of results' do
    #   VCR.use_cassette('moves') do
    #     expect(response.count).to be 4
    #   end
    # end
  end

  describe '.anonymise' do
    let(:original) do
      {
        'offenderNo': 'V6537TX',
        'createDateTime': '2019-07-24T08:10:58',
        'eventId': 123,
        'fromAgency': 'WEI',
        'fromAgencyDescription': 'WEALSTUN (HMP)',
        'toAgency': 'LEI',
        'toAgencyDescription': 'LEEDS (HMP)',
        'eventDate': '2019-07-24',
        'startTime': '2019-07-24T17:00:00',
        'endTime': nil,
        'eventClass': 'EXT_MOV',
        'eventType': 'CRT',
        'eventSubType': 'PR',
        'eventStatus': 'COMP',
        'judgeName': 'Bob',
        'directionCode': 'IN',
        'commentText': 'Comment about the move',
        'bookingActiveFlag': true,
        'bookingInOutStatus': 'IN'
      }
    end
    let(:offender_number) { 'D1234VG' }
    let(:anonymised) { described_class.anonymise(offender_number, original) }

    it 'changes the offender number' do
      expect(anonymised[:offenderNo]).to eq offender_number
    end

    it 'resets commentText' do
      expect(anonymised[:commentText]).to be_nil
    end

    it 'resets judgeName' do
      expect(anonymised[:judgeName]).to be_nil
    end
  end
end
