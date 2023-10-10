# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MovesController do
  describe 'GET /moves/:move_id' do
    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body).deep_symbolize_keys }
    let(:move) { create(:move) }
    let(:move_id) { move.id }

    before do
      get "/api/moves/#{move_id}", headers:, as: :json
    end

    context 'when successful' do
      let(:schema) { load_yaml_schema('get_move_responses.yaml') }
      let(:data) do
        {
          id: move_id,
          type: 'moves',
          attributes: {
            status: move.status,
            move_type: move.move_type,
            reference: move.reference,
            date: move.date.iso8601,
            date_from: move.date_from.iso8601,
            date_to: nil,
            time_due: move.time_due.iso8601,
            move_agreed: move.move_agreed,
            move_agreed_by: move.move_agreed_by,
            rejection_reason: move.rejection_reason,
            nomis_event_id: move.nomis_event_id,
            additional_information: move.additional_information,
            cancellation_reason: move.cancellation_reason,
            cancellation_reason_comment: move.cancellation_reason_comment,
            created_at: move.created_at.iso8601,
            updated_at: move.updated_at.iso8601,
          },
          relationships: {
            allocation: {
              data: nil,
            },
            court_hearings: {
              data: [],
            },
            documents: {
              data: [],
            },
            from_location: {
              data: {
                id: move.from_location.id,
                type: 'locations',
              },
            },
            original_move: {
              data: nil,
            },
            person: {
              data: {
                id: move.person.id,
                type: 'people',
              },
            },
            prison_transfer_reason: {
              data: nil,
            },
            profile: {
              data: {
                id: move.profile.id,
                type: 'profiles',
              },
            },
            to_location: {
              data: {
                id: move.to_location.id,
                type: 'locations',
              },
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data:)
      end
    end

    context 'when unsuccessful' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }

      context 'when attempting to access an unknown move' do
        let(:move_id) { SecureRandom.uuid }
        let(:detail_404) { "Couldn't find Move with 'id'=#{move_id}" }

        it_behaves_like 'an endpoint that responds with error 404'
      end
    end
  end
end
