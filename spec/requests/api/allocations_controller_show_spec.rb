# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::AllocationsController do
  describe 'GET /allocations/:allocation_id' do
    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body).deep_symbolize_keys }
    let(:allocation) { create(:allocation, :with_moves) }
    let(:allocation_id) { allocation.id }

    before do
      get "/api/allocations/#{allocation_id}", headers: headers, as: :json
    end

    context 'when successful' do
      let(:schema) { load_yaml_schema('get_allocation_responses.yaml') }
      let(:data) do
        {
          id: allocation.id,
          type: 'allocations',
          attributes: {
            moves_count: allocation.moves_count,
            date: allocation.date.iso8601,
            estate: allocation.estate,
            estate_comment: allocation.estate_comment,
            prisoner_category: allocation.prisoner_category,
            sentence_length: allocation.sentence_length,
            sentence_length_comment: allocation.sentence_length_comment,
            complex_cases: allocation.complex_cases,
            complete_in_full: allocation.complete_in_full,
            requested_by: allocation.requested_by,
            other_criteria: allocation.other_criteria,
            status: allocation.status,
            cancellation_reason: allocation.cancellation_reason,
            cancellation_reason_comment: allocation.cancellation_reason_comment,
            created_at: allocation.created_at.iso8601,
            updated_at: allocation.updated_at.iso8601,
          },
          meta: {
            moves: {
              total: 1,
              filled: 1,
              unfilled: 0,
            },
          },
          relationships: {
            from_location: {
              data: {
                id: allocation.from_location.id,
                type: 'locations',
              },
            },
            to_location: {
              data: {
                id: allocation.to_location.id,
                type: 'locations',
              },
            },
            moves: {
              data: [
                {
                  id: allocation.moves.first.id,
                  type: 'moves',
                },
              ],
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when unsuccessful' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }

      context 'when attempting to access an unknown allocation' do
        let(:allocation_id) { SecureRandom.uuid }
        let(:detail_404) { "Couldn't find Allocation with 'id'=#{allocation_id}" }

        it_behaves_like 'an endpoint that responds with error 404'
      end
    end
  end
end
