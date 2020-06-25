# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MoveEventsController do
  describe 'POST /moves/:move_id/accept' do
    include_context 'with supplier with access token'
    include_context 'with mock redis'

    let(:response_json) { JSON.parse(response.body) }
    let(:from_location) { create(:location, suppliers: [supplier]) }
    let(:move) { create(:move, :proposed, from_location: from_location) }
    let(:move_id) { move.id }

    before do
      post("/api/v1/moves/#{move_id}/accept", params: params, headers: headers, as: :json)
    end

    context 'with happy params' do
      let(:params) do
        {
          data: {
            type: 'accepts',
            attributes: {
              timestamp: '2020-04-23T18:25:43.511Z',
              notes: 'something noteworthy',
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 204'

      it 'changes the move to booked' do
        expect(move.reload).to be_booked
      end
    end

    context 'with unhappy params' do
      let(:params) { { foo: 'bar' } }

      it_behaves_like 'an endpoint that responds with error 400'
    end
  end
end
