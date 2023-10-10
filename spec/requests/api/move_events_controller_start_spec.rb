# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MoveEventsController do
  let(:response_json) { JSON.parse(response.body) }

  describe 'POST /moves/:move_id/start' do
    include_context 'with supplier with spoofed access token'

    let(:from_location) { create(:location, suppliers: [supplier]) }
    let(:move) { create(:move, :booked, from_location:) }
    let(:move_id) { move.id }

    before do
      post("/api/v1/moves/#{move_id}/start", params:, headers:, as: :json)
    end

    context 'with happy params' do
      let(:params) do
        {
          data: {
            type: 'starts',
            attributes: {
              timestamp: '2020-04-23T18:25:43.511Z',
              notes: 'something noteworthy',
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 204'

      it 'changes the move to in_transit' do
        expect(move.reload).to be_in_transit
      end

      it 'creates a move start event' do
        expect(GenericEvent::MoveStart.count).to eq(1)
      end
    end

    context 'with unhappy params' do
      let(:params) { { foo: 'bar' } }

      it_behaves_like 'an endpoint that responds with error 400'
    end
  end
end
