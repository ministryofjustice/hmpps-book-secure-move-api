# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PeopleController do
  let(:access_token) { 'spoofed-token' }
  let(:headers) { { 'CONTENT_TYPE': content_type, 'Authorization': "Bearer #{access_token}" } }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }
  let(:booking_id) { '1150262' }

  let(:nomis_activities) { [] }
  let(:nomis_court_hearings) { [] }
  let(:date_from) { Time.zone.today }
  let(:date_to) { Date.tomorrow }

  let(:params) do
    {
      filter: {
        date_from: date_from.iso8601,
        date_to: date_to.iso8601,
      },
    }
  end

  before do
    allow(People::RetrieveTimetable).to receive(:call).and_call_original
    allow(People::RetrieveActivities).to receive(:call).and_return(nomis_activities_struct)
    allow(People::RetrieveCourtHearings).to receive(:call).and_return(nomis_court_hearings_struct)
  end

  context 'when person is present' do
    let(:person) { create(:person, :nomis_synced, latest_nomis_booking_id: booking_id) }
    let(:nomis_success) { true }

    let(:nomis_court_hearings_struct) do
      OpenStruct.new(
        success?: nomis_success,
        content: nomis_court_hearings,
        error: nil,
      )
    end
    let(:nomis_activities_struct) do
      OpenStruct.new(
        success?: nomis_success,
        content: nomis_activities,
        error: nil,
      )
    end

    context 'when timetable entries are present in Nomis' do
      let(:nomis_success) { true }
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

      it 'returns 200' do
        get("/api/v1/people/#{person.id}/timetable", headers:, params:)

        expect(response).to have_http_status(:success)
      end

      it 'returns location relationships' do
        create :location

        get("/api/v1/people/#{person.id}/timetable", headers:, params:)

        expect(response_json['included']).to be_a_kind_of Array
        expect(response_json['included'].first['type']).to eq 'locations'
      end

      it 'calls the People::RetrieveTimetable service with the correct filter params' do
        get("/api/v1/people/#{person.id}/timetable", headers:, params:)

        expect(People::RetrieveCourtHearings).to have_received(:call).with(an_instance_of(Person), date_from, date_to)
      end

      context 'when we pass an include in the query params' do
        it 'includes location in the response' do
          create(:location)
          get("/api/v1/people/#{person.id}/timetable?include=location", headers:, params:)

          expect(response_json['included'].first['type']).to eq('locations')
        end

        it 'throws an error if query param invalid ' do
          get("/api/v1/people/#{person.id}/timetable?include=foo.bar", headers:, params:)

          expect(response).to have_http_status(:bad_request)
        end
      end
    end

    context 'when person does not exist' do
      it 'returns 404' do
        person_id = 'non-existent-person'

        get("/api/v1/people/#{person_id}/timetable", headers:, params:)

        expect(response_json['errors'][0]['title']).to eq('Resource not found')
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when filter[date_from] or filter[date_to] are invalid' do
      let(:params) do
        {
          filter: {
            date_from: '10-10-2019',
            date_to: '11-10-2019',
          },
        }
      end

      it 'returns 400' do
        get("/api/v1/people/#{person.id}/timetable", headers:, params:)

        expect(response_json['errors'][0]['detail']).to eq('is not a valid iso8601 date.')
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when the timetable entries are not present in Nomis' do
      let(:nomis_activities) { [] }
      let(:nomis_court_hearings) { [] }

      it 'return an empty data key' do
        get("/api/v1/people/#{person.id}/timetable", headers:, params:)

        expect(response_json['data']).to eq([])
        expect(response).to have_http_status(:success)
      end
    end

    context 'when filter params are missing' do
      let(:nomis_activities) { [] }
      let(:nomis_court_hearings) { [] }

      let(:params) { {} }

      it 'returns an error' do
        get("/api/v1/people/#{person.id}/timetable", headers:, params:)

        expect(response_json['errors'][0]['detail']).to match(/param is missing or the value is empty: filter/)
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
