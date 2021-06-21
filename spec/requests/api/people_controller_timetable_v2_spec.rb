# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PeopleController do
  let(:access_token) { 'spoofed-token' }
  let(:person) { create(:person, :nomis_synced, latest_nomis_booking_id: '1150262') }
  let(:nomis_court_hearings_struct) do
    OpenStruct.new(
      success?: true,
      content: nomis_court_hearings,
      error: nil,
    )
  end
  let(:nomis_activities_struct) do
    OpenStruct.new(
      success?: true,
      content: nomis_activities,
      error: nil,
    )
  end
  let(:nomis_activities) do
    [
      Activity.new.build_from_nomis(
        'eventId' => 401_732_488,
        'startTime' => '2020-04-22T08:30:00',
        'eventTypeDesc' => 'Prison Activities',
        'locationCode' => 'PEI',
      ),
    ]
  end
  let(:nomis_court_hearings) do
    [
      NomisCourtHearing.new.build_from_nomis(
        'id' => 330_253_339,
        'dateTime' => '2017-01-27T10:00:00',
        'location' => { 'agencyId' => 'PEI' },
      ),
    ]
  end
  let(:response_json) { JSON.parse(response.body) }
  let(:date_from) { Date.today }
  let(:date_to) { Date.tomorrow }

  let(:params) do
    {
      filter: {
        date_from: date_from.iso8601,
        date_to: date_to.iso8601,
      },
    }
  end

  let(:headers) do
    {
      'CONTENT_TYPE': ApiController::CONTENT_TYPE,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  before do
    allow(People::RetrieveTimetable).to receive(:call).and_call_original
    allow(People::RetrieveActivities).to receive(:call).and_return(nomis_activities_struct)
    allow(People::RetrieveCourtHearings).to receive(:call).and_return(nomis_court_hearings_struct)
  end

  context 'when not including the include query param' do
    it 'returns no included relationships' do
      create(:location)
      get "/api/v1/people/#{person.id}/timetable", params: params, headers: headers

      expect(response_json).not_to include('included')
    end
  end
end
