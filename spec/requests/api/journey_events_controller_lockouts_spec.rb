# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::JourneyEventsController do
  describe 'POST /moves/:move_id/journeys/:journey_id/lockouts' do
    subject(:do_post) do
      post("/api/v1/moves/#{move_id}/journeys/#{journey_id}/lockouts", params: params, headers: headers, as: :json)
    end

    include_context 'with supplier with spoofed access token'

    let(:from_location) { create(:location, suppliers: [supplier]) }
    let(:move) { create(:move, from_location: from_location) }
    let(:move_id) { move.id }
    let(:journey) { create(:journey, initial_journey_state, move: move, supplier: supplier) }
    let(:journey_id) { journey.id }
    let(:initial_journey_state) { :in_progress }
    let(:location) { create(:location) }

    context 'with happy params' do
      let(:params) do
        {
          data: {
            type: 'lockouts',
            attributes: {
              timestamp: '2020-04-23T18:25:43.511Z',
              notes: 'something noteworthy',
            },
            relationships: { from_location: { data: { id: location.id } } },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 204' do
        before do
          do_post
        end
      end

      it 'writes a journey lockout event' do
        expect { do_post }.to change { GenericEvent::JourneyLockout.count }.by(1)
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
