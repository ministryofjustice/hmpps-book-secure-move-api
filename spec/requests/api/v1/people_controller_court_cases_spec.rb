# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PeopleController do
  let(:token) { create(:access_token) }
  let(:response_json) { JSON.parse(response.body) }
  let(:booking_id) { '1150262' }

  context 'when person is present ' do
    let(:person) { create(:profile, :nomis_synced).person }
    let(:court_cases_from_nomis) {
      [CourtCase.new.build_from_nomis('caseInfoNumber' => 'T20167984', 'beginDate' => '2020-01-01', 'agency' => { 'agencyId' => "SNARCC" }),
       CourtCase.new.build_from_nomis('caseInfoNumber' => 'T22222222', 'beginDate' => '2020-01-02', 'agency' => { 'agencyId' => "SNARCC" })]
    }

    before do
      allow(People::RetrieveCourtCases).to receive(:call).with(person).and_return(court_cases_from_nomis)

      person.latest_profile.update(latest_nomis_booking_id: booking_id)
      create :location, nomis_agency_id: 'SNARCC', title: 'Snaresbrook Crown Court', location_type: 'CRT'
    end

    it 'returns success' do
      get "/api/v1/people/#{person.id}/court_cases", params: { access_token: token.token }

      expect(response_json['data'][0]['id']).to eq('T20167984')
      expect(response_json['included']).not_to be_nil
    end
  end
end
