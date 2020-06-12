# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::JourneyEventsController do
  describe 'POST /moves/:move_id/journeys/:journey_id/lockouts' do
    include_context 'with supplier with move and journey'
    let(:initial_journey_state) { :in_progress }
    let(:location) { create(:location) }

    before do
      post("/api/v1/moves/#{move_id}/journeys/#{journey_id}/lockouts", params: params, headers: headers, as: :json)
    end

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

      it_behaves_like 'an endpoint that responds with success 204'

      it 'logs a lockout event record' do
        expect(journey.events.last.event_name).to eql('lockout')
      end
    end

    context 'with unhappy params' do
      let(:params) { { foo: 'bar' } }

      it_behaves_like 'an endpoint that responds with error 400'
    end
  end
end
