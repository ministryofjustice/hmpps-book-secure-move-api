# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activity do
  describe '#build_from_nomis' do
    subject(:activity) { described_class.new }

    let(:nomis_scheduled_event) do
      {
        'bookingId' => 771_697,
        'eventClass' => 'INT_MOV',
        'eventId' => 401_732_488,
        'eventStatus' => 'SCH',
        'eventType' => 'PRISON_ACT',
        'eventTypeDesc' => 'Prison Activities',
        'eventSubType' => 'PA',
        'eventSubTypeDesc' => 'Prison Activities',
        'eventDate' => '2020-04-22',
        'startTime' => '2020-04-22T08:30:00',
        'endTime' => '2020-04-22T11:45:00',
        'eventLocation' => 'CONTRACTS',
        'eventLocationId' => 76_748,
        'eventSource' => 'PA',
        'eventSourceCode' => 'CCONT1',
        'eventSourceDesc' => 'CAT C CONTRACTS 1',
        'paid' => false,
        'payRate' => 0.5,
        'locationCode' => 'CNCTS',
      }
    end
    let(:expected_attributes) do
      {
        id: nomis_scheduled_event['eventId'],
        start_time: Time.parse(nomis_scheduled_event['startTime']), # rubocop:disable Rails/TimeZone
        type: 'Prison Activities',
        reason: nomis_scheduled_event['eventTypeDesc'],
        agency_id: nomis_scheduled_event['locationCode'],
      }
    end

    it { expect(activity.build_from_nomis(nomis_scheduled_event)).to be_a(described_class) }
    it { expect(activity.build_from_nomis(nomis_scheduled_event)).to have_attributes(expected_attributes) }
  end
end
