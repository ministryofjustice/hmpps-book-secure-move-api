# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Api::MoveEventsController do
  describe 'POST /moves/:move_id/cancel' do
    include_context 'with supplier with spoofed access token'

    let(:schema) { load_yaml_schema('post_move_events_responses.yaml') }
    let(:response_json) { JSON.parse(response.body) }
    let(:from_location) { create(:location, suppliers: [supplier]) }
    let(:move) { create(:move, from_location: from_location) }
    let(:move_id) { move.id }
    let(:new_location) { create(:location) }
    let(:cancel_params) do
      {
        data: {
          type: 'cancel',
          attributes: {
            timestamp: '2020-04-23T18:25:43.511Z',
            cancellation_reason: 'supplier_declined_to_move',
            cancellation_reason_comment: 'no room on the bus',
            notes: 'something went wrong',
          },
        },
      }
    end

    before do
      allow(Allocations::RemoveFromNomis).to receive(:call)
      allow(Notifier).to receive(:prepare_notifications)
      post "/api/v1/moves/#{move_id}/cancel", params: cancel_params, headers: headers, as: :json
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 204'

      it 'updates the move status' do
        expect(move.reload.status).to eql('cancelled')
      end

      it 'updates the move cancellation_reason' do
        expect(move.reload.cancellation_reason).to eql('supplier_declined_to_move')
      end

      it 'updates the move cancellation_reason_comment' do
        expect(move.reload.cancellation_reason_comment).to eql('no room on the bus')
      end

      it 'removes a prison transfer event from Nomis' do
        expect(Allocations::RemoveFromNomis).to have_received(:call).with(move)
      end

      it 'creates a move cancel event' do
        expect(GenericEvent::MoveCancel.count).to eq(1)
      end

      describe 'webhook and email notifications' do
        it 'calls the notifier when updating a person' do
          expect(Notifier).to have_received(:prepare_notifications).with(topic: move, action_name: 'update_status')
        end
      end
    end

    context 'with a bad request' do
      let(:cancel_params) { nil }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'with a missing move_id' do
      let(:move_id) { 'foo-bar' }
      let(:detail_404) { "Couldn't find Move with 'id'=foo-bar" }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with validation errors' do
      context 'with a bad timestamp' do
        let(:cancel_params) { { data: { type: 'cancel', attributes: { timestamp: 'Foo-Bar', cancellation_reason: 'rejected' } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Invalid timestamp', 'detail' => 'Validation failed: Timestamp must be formatted as a valid ISO-8601 date-time' }] }
        end
      end

      context 'with a bad event type' do
        let(:cancel_params) { { data: { type: 'Foo-bar', attributes: { timestamp: '2020-04-23T18:25:43.511Z', cancellation_reason: 'rejected' } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Invalid type', 'detail' => 'Validation failed: Type is not included in the list' }] }
        end
      end

      context 'with a bad cancellation_reason' do
        let(:cancel_params) { { data: { type: 'cancel', attributes: { timestamp: '2020-04-23T18:25:43.511Z', cancellation_reason: 'Yo ho ho' } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Invalid cancellation_reason', 'detail' => 'Validation failed: Cancellation reason is not included in the list' }] }
        end
      end

      context 'with a missing cancellation_reason' do
        let(:cancel_params) { { data: { type: 'cancel', attributes: { timestamp: '2020-04-23T18:25:43.511Z' } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Invalid cancellation_reason', 'detail' => 'Validation failed: Cancellation reason is not included in the list' }] }
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
