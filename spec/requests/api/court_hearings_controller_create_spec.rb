# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::CourtHearingsController do
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

    let(:access_token) { 'spoofed-token' }
    let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
    let(:content_type) { ApiController::CONTENT_TYPE }

    it 'returns 201' do
      post '/api/v1/court_hearings', params: { data: }, headers:, as: :json

      expect(response).to have_http_status(:created)
    end

    it 'creates a court_hearing' do
      expect { post '/api/v1/court_hearings', params: { data: }, headers:, as: :json }
        .to change(CourtHearing, :count).by(1)
    end

    context 'when a move relationship is passed' do
      before do
        allow(CourtHearings::CreateInNomis).to receive(:call)
      end

      let(:move) { create(:move) }

      let(:data) do
        {
          type: 'court_hearings',
          attributes: court_hearing_attributes,
          relationships: { move: { data: { type: 'moves', id: move.id } } },
        }
      end

      it 'sets the correct relationship with the move' do
        post '/api/v1/court_hearings', params: { data: }, headers:, as: :json

        court_hearing = CourtHearing.find(response_json['data']['id'])

        expect(move.court_hearings).to include(court_hearing)
      end

      context 'when do_not_save_to_nomis param is true' do
        let(:query_params) { '?do_not_save_to_nomis=true' }

        it 'creates the court hearings in Nomis' do
          post "/api/v1/court_hearings#{query_params}", params: { data: }, headers:, as: :json

          expect(CourtHearings::CreateInNomis).not_to have_received(:call).with(move, move.court_hearings)
        end
      end

      context 'when do_not_save_to_nomis param is not true' do
        let(:query_params) { '?do_not_save_to_nomis=foo' }

        it 'creates the court hearings in Nomis' do
          post "/api/v1/court_hearings#{query_params}", params: { data: }, headers:, as: :json

          expect(CourtHearings::CreateInNomis).to have_received(:call).with(move, move.court_hearings)
        end
      end

      context 'when do_not_save_to_nomis param is not present' do
        let(:query_params) { '' }

        it 'creates the court hearings in Nomis' do
          post "/api/v1/court_hearings#{query_params}", params: { data: }, headers:, as: :json

          expect(CourtHearings::CreateInNomis).to have_received(:call).with(move, move.court_hearings)
        end
      end
    end
  end
end
