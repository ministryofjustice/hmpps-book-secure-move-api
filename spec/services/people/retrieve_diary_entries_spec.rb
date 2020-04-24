# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::RetrieveDiaryEntries do
  let(:person) { instance_double('Person') }

  before do
    allow(People::RetrieveCourtHearings).to receive(:call).and_return(nomis_court_hearings)
    allow(People::RetrieveActivities).to receive(:call).and_return(nomis_activities)
  end

  let(:court_hearing) do
    NomisCourtHearing.new.build_from_nomis(
      {
        'dateTime' => '2017-01-27T10:00:00',
        'location' => {
          'agencyId' => 'SNARCC',
        }
      }
    )
  end
  let(:activity) do
    Activity.new.build_from_nomis(
      'startTime' => '2020-04-22T08:30:00'
    )
  end

  let(:nomis_court_hearings) { [court_hearing] }
  let(:nomis_activities) { [activity] }

  it 'calls the right services with the correct args' do
    described_class.call(person)

    expect(People::RetrieveActivities).to have_received(:call).with(person)
    expect(People::RetrieveCourtHearings).to have_received(:call).with(person)
  end

  it 'sorts diary entries in descending order by start time' do
    expect(described_class.call(person)).to eq([activity, court_hearing])
  end
end
