# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::JourneyEventsController do
  describe 'POST /moves/:move_id/journeys/:journey_id/uncancel' do
    subject(:do_post) do
      post("/api/v1/moves/#{move_id}/journeys/#{journey_id}/uncancel", params: params, headers: headers, as: :json)
    end

    include_context 'with supplier with spoofed access token'

    let(:from_location) { create(:location, suppliers: [supplier]) }
    let(:move) { create(:move, from_location: from_location) }
    let(:move_id) { move.id }
    let(:journey) { create(:journey, initial_journey_state, move: move, supplier: supplier) }
    let(:journey_id) { journey.id }
    let(:initial_journey_state) { :cancelled }

    context 'with happy params' do
      let(:params) do
        {
          data: {
            type: 'uncancels',
            attributes: {
              timestamp: '2020-04-23T18:25:43.511Z',
              notes: 'something noteworthy',
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 204' do
        before do
          do_post
        end
      end

      it 'uncancels the journey' do
        do_post
        expect(journey.reload).to be_in_progress
      end

      it 'dual writes a journey uncancel event' do
        pending 'need to link generic events to the original event to enable debug/rollback behaviour'
        expect { do_post }.to change { GenericEvent::JourneyUncancel.count }.by(1)
      end
    end

    context 'with unhappy params' do
      let(:params) { { foo: 'bar' } }

      it_behaves_like 'an endpoint that responds with error 400' do
        before do
          do_post
        end
      end
    end
  end
end
