# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MoveEventsController do
  describe 'POST /moves/:move_id/complete' do
    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body) }
    let(:schema) { load_yaml_schema('post_move_events_responses.yaml') }
    let(:from_location) { create(:location, suppliers: [supplier]) }
    let(:move) { create(:move, :in_transit, from_location:) }
    let(:move_id) { move.id }

    let(:complete_params) do
      {
        data: {
          type: 'complete',
          attributes: {
            timestamp: '2020-04-23T18:25:43.511Z',
            notes: 'jobs a good un',
          },
        },
      }
    end

    before do
      allow(Notifier).to receive(:prepare_notifications)
      post "/api/v1/moves/#{move_id}/complete", params: complete_params, headers:, as: :json
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 204'

      it 'updates the move status' do
        expect(move.reload.status).to eql('completed')
      end

      it 'creates a move complete event' do
        expect(GenericEvent::MoveComplete.count).to eq(1)
      end

      describe 'webhook and email notifications' do
        it 'calls the notifier when updating a person' do
          expect(Notifier).to have_received(:prepare_notifications).with(topic: move, action_name: 'update_status')
        end
      end
    end

    context 'with a bad request' do
      let(:complete_params) { nil }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'with a missing move_id' do
      let(:move_id) { 'foo-bar' }
      let(:detail_404) { "Couldn't find Move with 'id'=foo-bar" }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with validation errors' do
      context 'with a bad timestamp' do
        let(:complete_params) { { data: { type: 'complete', attributes: { timestamp: 'Foo-Bar' } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Invalid timestamp', 'detail' => 'Validation failed: Timestamp must be formatted as a valid ISO-8601 date-time' }] }
        end
      end

      context 'with a bad event type' do
        let(:complete_params) { { data: { type: 'Foo-bar', attributes: { timestamp: '2020-04-23T18:25:43.511Z' } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Invalid type', 'detail' => 'Validation failed: Type is not included in the list' }] }
        end
      end
    end
  end
end
