# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::RetrieveTimetable do
  before do
    allow(People::RetrieveCourtHearings).to receive(:call).and_return(nomis_court_hearings_struct)
    allow(People::RetrieveActivities).to receive(:call).and_return(nomis_activities_struct)
  end

  let(:person) { instance_double('Person') }
  let(:date_from) { Time.zone.today }
  let(:date_to) { Date.tomorrow }

  let(:nomis_court_hearings_struct) do
    OpenStruct.new(
      success?: nomis_success,
      content: [court_hearing],
      error: nil,
    )
  end
  let(:nomis_activities_struct) do
    OpenStruct.new(
      success?: nomis_success,
      content: [activity],
      error: nil,
    )
  end
  let(:court_hearing) do
    NomisCourtHearing.new.build_from_nomis(
      'dateTime' => '2017-01-27T10:00:00',
      'location' => {
        'agencyId' => 'SNARCC',
      },
    )
  end
  let(:activity) do
    Activity.new.build_from_nomis(
      'startTime' => '2020-04-22T08:30:00',
    )
  end

  context 'when retrieving from Nomis succeeds' do
    let(:nomis_success) { true }

    it 'calls the right services with the correct args' do
      described_class.call(person, date_from, date_to)

      expect(People::RetrieveActivities).to have_received(:call).with(person, date_from, date_to)
      expect(People::RetrieveCourtHearings).to have_received(:call).with(person, date_from, date_to)
    end

    it 'sorts timetable entries in ascending order by start time' do
      expect(described_class.call(person, date_from, date_to).content).to eq([court_hearing, activity])
    end
  end

  context 'when retrieving from Nomis fails' do
    let(:nomis_success) { false }

    it 'returns a struct indicating that calling to Nomis failed' do
      struct = described_class.call(person, date_from, date_to)

      expect(struct).not_to be_success
    end

    it 'returns early for the first error' do
      described_class.call(person, date_from, date_to)

      expect(People::RetrieveActivities).to have_received(:call).with(person, date_from, date_to)
      expect(People::RetrieveCourtHearings).not_to have_received(:call).with(person, date_from, date_to)
    end
  end
end
