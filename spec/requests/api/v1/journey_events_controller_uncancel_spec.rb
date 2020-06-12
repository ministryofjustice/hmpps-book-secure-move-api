# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::JourneyEventsController do
  describe 'POST /moves/:move_id/journeys/:journey_id/uncancel' do
    include_context 'with supplier with move and journey'
    let(:initial_journey_state) { :cancelled }

    before do
      post("/api/v1/moves/#{move_id}/journeys/#{journey_id}/uncancel", params: params, headers: headers, as: :json)
    end

    context 'with happy params' do
      let(:params) do
        {
          data: {
            type: 'uncancel',
            attributes: {
              timestamp: '2020-04-23T18:25:43.511Z',
              notes: 'something noteworthy',
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 204'

      it 'uncancels the journey' do
        expect(journey.reload).to be_in_progress
      end
    end

    context 'with unhappy params' do
      let(:params) { { foo: 'bar' } }

      it_behaves_like 'an endpoint that responds with error 400'
    end
  end
end
