# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::JourneyEventsController do
  describe 'POST /moves/:move_id/journeys/:journey_id/uncancel' do
    subject(:do_post) do
      post("/api/v1/moves/#{move.id}/journeys/#{journey_id}/uncancel", params: params, headers: headers, as: :json)
    end

    include_context 'with supplier with spoofed access token'

    let(:move) { create(:move, from_location: create(:location, suppliers: [supplier])) }
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

      it 'writes a journey uncancel event' do
        expect { do_post }.to change(GenericEvent::JourneyUncancel, :count).by(1)
      end

      it 'sets the correct created_by' do
        do_post
        event = GenericEvent.last
        expect(event.created_by).to eq('TEST_USER')
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
