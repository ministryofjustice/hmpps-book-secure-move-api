# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PeopleController do
  let(:token) { create(:access_token) }
  let(:response_json) { JSON.parse(response.body) }
  let(:booking_id) { '1150262' }

  context 'when person is present ' do
    let(:person) { create(:profile, :nomis_synced).person }

    context 'when the court cases are present in Nomis ' do
      let(:court_cases_from_nomis) {
        OpenStruct.new(success?: true, court_cases:
            [CourtCase.new.build_from_nomis('id' => '1495077', 'beginDate' => '2020-01-01', 'agency' => { 'agencyId' => 'SNARCC' }),
             CourtCase.new.build_from_nomis('id' => '2222222', 'beginDate' => '2020-01-02', 'agency' => { 'agencyId' => 'SNARCC' })])
      }

      before do
        person.latest_profile.update(latest_nomis_booking_id: booking_id)

        allow(People::RetrieveCourtCases).to receive(:call).and_return(court_cases_from_nomis)
      end

      it 'returns success' do
        get "/api/v1/people/#{person.id}/court_cases", params: { access_token: token.token }

        expect(response_json['data'][0]['id']).to eq('1495077')
      end

      it 'includes location in the response' do
        create :location, nomis_agency_id: 'SNARCC', title: 'Snaresbrook Crown Court', location_type: 'CRT'

        get "/api/v1/people/#{person.id}/court_cases", params: { access_token: token.token }

        expect(response_json['included']).to be_a_kind_of Array
        expect(response_json['included'].first['type']).to eq 'locations'
      end


      context 'when we pass a filter in the query params' do
        let(:query) { '?filter[active]=true' }

        it 'passes the filter to the RetrieveCourtCases service' do
          get "/api/v1/people/#{person.id}/court_cases#{query}", params: { access_token: token.token }

          expect(People::RetrieveCourtCases).to have_received(:call).with(person, 'active' => 'true')
        end
      end
    end

    context 'when person does not exist' do
      let(:person_id) { 'non-existent-person' }

      it 'returns success' do
        get "/api/v1/people/#{person_id}/court_cases", params: { access_token: token.token }

        expect(response_json['errors'][0]['title']).to eq('Resource not found')
      end
    end

    context 'when booking is empty' do
      let(:booking_id) { nil }

      it 'returns success' do
        person.latest_profile.update(latest_nomis_booking_id: booking_id)

        get "/api/v1/people/#{person.id}/court_cases", params: { access_token: token.token }

        expect(response_json['errors'][0]['detail']).to eq("Latest nomis booking id can't be blank")
      end
    end

    context 'when the court cases are NOT present in Nomis' do
      let(:booking_id) { '123456789' }

      let(:court_cases_from_nomis) { OpenStruct.new(success?: false, error: NomisClient::ApiError.new(status: 404, error_body: '{}')) }

      it 'return 404 not found' do
        allow(People::RetrieveCourtCases).to receive(:call).and_return(court_cases_from_nomis)

        get "/api/v1/people/#{person.id}/court_cases", params: { access_token: token.token }

        expect(response_json['errors']).to be_a_kind_of Array
      end
    end
  end
end
