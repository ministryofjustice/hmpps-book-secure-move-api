# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CourtHearingsController do
  let(:response_json) { JSON.parse(response.body) }

  describe 'POST /court_hearings' do
    let(:court_hearing_attributes) do
      {
        'start_time': '2018-01-01T18:57Z',
        'case_start_date': '2018-01-01',
        'case_number': 'T32423423423',
        'nomis_case_id': '4232423',
        'case_type': 'Adult',
        'comments': 'Witness for Foo Bar',
      }
    end

    let(:data) do
      {
        type: 'court_hearings',
        attributes: court_hearing_attributes,
      }
    end

    let(:supplier) { create(:supplier) }
    let(:application) { create(:application, owner_id: supplier.id) }
    let(:access_token) { create(:access_token, application: application).token }
    let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
    let(:content_type) { ApiController::CONTENT_TYPE }

    it 'returns 201' do
      post '/api/v1/court_hearings', params: { data: data }, headers: headers, as: :json

      expect(response).to have_http_status(:created)
    end

    it 'creates a court_hearing' do
      expect { post '/api/v1/court_hearings', params: { data: data }, headers: headers, as: :json }.
        to change(CourtHearing, :count).by(1)
    end

    context 'when a move relationship is passed' do
      let(:move) { create(:move) }

      let(:data) do
        {
          type: 'court_hearings',
          attributes: court_hearing_attributes,
          relationships: { moves: { data: { type: 'moves', id: move.id } } },
        }
      end

      it 'sets the correct relationship with the move' do
        post '/api/v1/court_hearings', params: { data: data }, headers: headers, as: :json

        court_hearing = CourtHearing.find(response_json['data']['id'])

        expect(move.court_hearings).to include(court_hearing)
      end
    end
  end
end
