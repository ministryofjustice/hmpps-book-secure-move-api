# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::Anonymiser do
  subject(:anonymiser) do
    described_class.new(move: move)
  end

  let(:nomis_offender_number) { 'D1234VG' }
  let(:day_offset) { 1 }
  let(:move) do
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

  describe '.call' do
    let(:anonymised) do
      anonymiser.call
    end

    it 'changes the offender number' do
      expect(anonymised[:person_nomis_prison_number]).not_to eq nomis_offender_number
    end

    it 'sets date to tomorrow' do
      expect(anonymised[:date]).to eq "<%= date.toISOString().split('T')[0] %>"
    end

    it 'sets time_due to 17:00' do
      expect(anonymised[:time_due]).to eq "<%= date.toISOString().split('T')[0] + 'T' + '17:00:00' %>"
    end
  end
end
