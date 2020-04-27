# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PeopleController do
  let(:token) { create(:access_token) }
  let(:response_json) { JSON.parse(response.body) }
  let(:booking_id) { '1150262' }

  let(:nomis_activities) { [] }
  let(:nomis_court_hearings) { [] }

  before do
    allow(People::RetrieveActivities).to receive(:call).and_return(nomis_activities)
    allow(People::RetrieveCourtHearings).to receive(:call).and_return(nomis_court_hearings)

  end

  context 'when person is present ' do
    before do
      person.latest_profile.update(latest_nomis_booking_id: booking_id)
    end

    let(:person) { create(:profile, :nomis_synced).person }

    context 'when timetable entries are present in Nomis' do
      let(:nomis_activities) do
        [
          Activity.new.build_from_nomis(
            'eventId' => 401732488,
            'startTime' => '2020-04-22T08:30:00',
            'eventTypeDesc' => 'Prison Activities',
            'locationCode' => 'PEI',
          )
        ]
      end
      let(:nomis_court_hearings) do
        [
          NomisCourtHearing.new.build_from_nomis(
            'id' => 330253339,
            'dateTime' => '2017-01-27T10:00:00',
            'location' => { 'agencyId' => 'PEI' },
          )
        ]
      end


      it 'returns 200' do
        get "/api/v1/people/#{person.id}/timetable", params: { access_token: token.token }

        expect(response).to have_http_status(:success)
      end

      it 'returns location relationships' do
        create :location

        get "/api/v1/people/#{person.id}/timetable", params: { access_token: token.token }
        expect(response_json['included']).to be_a_kind_of Array
        expect(response_json['included'].first['type']).to eq 'locations'
      end
    end

    context 'when person does not exist' do
      it 'returns success' do
        person_id = 'non-existent-person'

        get "/api/v1/people/#{person_id}/timetable", params: { access_token: token.token }

        expect(response_json['errors'][0]['title']).to eq('Resource not found')
      end
    end

    context 'when the timetable entries are not present in Nomis' do
      let(:nomis_activities) { [] }
      let(:nomis_court_hearings) { [] }

      it 'return 404 not found' do
        get "/api/v1/people/#{person.id}/timetable", params: { access_token: token.token }

        expect(response_json).to eq('data'=>[])
      end
    end
  end
end
