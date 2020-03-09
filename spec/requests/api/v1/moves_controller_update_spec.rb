# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController do
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  let(:resource_to_json) do
    JSON.parse(ActionController::Base.render(json: move.reload, include: MoveSerializer::INCLUDED_ATTRIBUTES))
  end

  let(:detail_404) { "Couldn't find Move with 'id'=UUID-not-found" }

  describe 'PATCH /moves' do
    let(:schema) { load_json_schema('patch_move_responses.json') }

    let!(:move) { create :move, move_type: 'prison_recall' }
    let(:move_id) { move.id }
    let(:person) { create(:person) }
    let(:date_from) { Date.yesterday }
    let(:date_to) { Date.tomorrow }

    let(:move_params) do
      {
        type: 'moves',
        attributes: {
          status: 'cancelled',
          additional_information: 'some more info',
          cancellation_reason: 'other',
          cancellation_reason_comment: 'some other reason',
          move_type: 'court_appearance',
          move_agreed: true,
          move_agreed_by: 'Fred Bloggs',
          date_from: date_from,
          date_to: date_to,
        },
      }
    end

    before do
      next if RSpec.current_example.metadata[:skip_before]

      patch "/api/v1/moves/#{move_id}", params: { data: move_params }, headers: headers, as: :json
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      let(:detail_401) { 'Token expired or invalid' }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'when authorized' do
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{token.token}") }
      let(:token) { create(:access_token) }

      context 'when successful' do
        let(:result) { move.reload }

        it_behaves_like 'an endpoint that responds with success 200'

        it 'updates the status of a move' do
          expect(result.status).to eq 'cancelled'
        end

        it 'does not update the move type' do
          expect(result.move_type).to eq('prison_recall')
        end

        it 'updates move_agreed' do
          expect(result.move_agreed).to be true
        end

        it 'updates move_agreed_by' do
          expect(result.move_agreed_by).to eq 'Fred Bloggs'
        end

        it 'updates date_from' do
          expect(result.date_from).to eq date_from
        end

        it 'updates date_to' do
          expect(result.date_to).to eq date_to
        end
        it 'updates the additional_information of a move' do
          expect(result.additional_information).to eq 'some more info'
        end

        it 'updates the cancellation_reason of a move' do
          expect(result.cancellation_reason).to eq 'other'
        end

        it 'updates the cancellation_reason_comment of a move' do
          expect(result.cancellation_reason_comment).to eq 'some other reason'
        end

        it 'returns the correct data' do
          expect(response_json).to eq resource_to_json
        end
      end

      context 'with a read-only attribute' do
        let!(:move) { create :move }

        let(:move_params) do
          {
            type: 'moves',
            attributes: {
              status: 'cancelled',
              reference: 'new reference',
            },
          }
        end

        it_behaves_like 'an endpoint that responds with success 200'

        it 'updates the status of a move', skip_before: true do
          patch "/api/v1/moves/#{move_id}", params: { data: move_params }, headers: headers, as: :json
          expect(move.reload.status).to eq 'cancelled'
        end

        it 'does NOT update the reference of a move', skip_before: true do
          expect { patch("/api/v1/moves/#{move_id}", params: { data: move_params }, headers: headers, as: :json) }.not_to(
            change { move.reload.reference },
            )
        end
      end

      context 'with a bad request' do
        let(:move_params) { nil }

        it_behaves_like 'an endpoint that responds with error 400'
      end

      context 'when from nomis' do
        let(:nomis_event_id) { 12_345_678 }
        let!(:move) { create :move, nomis_event_ids: [nomis_event_id] }
        let(:detail_403) { 'Can\'t change moves coming from Nomis' }

        let(:move_params) do
          {
            type: 'moves',
            attributes: {
              status: 'cancelled',
              reference: 'new reference',
            },
          }
        end

        it_behaves_like 'an endpoint that responds with error 403'
      end

      context 'with a missing move' do
        let(:move_id) { 'null' }
        let(:detail_404) { "Couldn't find Move with 'id'=null" }

        it_behaves_like 'an endpoint that responds with error 404'
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:content_type) { 'application/xml' }

        it_behaves_like 'an endpoint that responds with error 415'
      end

      context 'with validation errors' do
        let(:move_params) do
          {
            type: 'moves',
            attributes: {
              status: 'invalid',
            },
          }
        end

        let(:errors_422) do
          [
            {
              'title' => 'Unprocessable entity',
              'detail' => 'Status is not included in the list',
              'source' => { 'pointer' => '/data/attributes/status' },
              'code' => 'inclusion',
            },
          ]
        end

        it_behaves_like 'an endpoint that responds with error 422'
      end
    end
  end
end
