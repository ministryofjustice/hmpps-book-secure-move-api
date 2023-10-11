# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MoveEventsController do
  describe 'POST /moves/:move_id/reject' do
    include_context 'with supplier with spoofed access token'

    let(:schema) { load_yaml_schema('post_move_events_responses.yaml') }
    let(:response_json) { JSON.parse(response.body) }

    let(:from_location) { create(:location, suppliers: [supplier]) }
    let(:move) { create(:move, from_location:) }
    let(:move_id) { move.id }
    let(:reject_params) do
      {
        data: {
          type: 'reject',
          attributes: {
            timestamp: '2020-04-23T18:25:43.511Z',
            rejection_reason: 'no_space_at_receiving_prison',
            cancellation_reason_comment: 'no room on the broom',
            rebook: 'true',
          },
        },
      }
    end

    before do
      allow(Notifier).to receive(:prepare_notifications)
      post "/api/v1/moves/#{move_id}/reject", params: reject_params, headers:, as: :json
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 204'

      it 'updates the move status' do
        expect(move.reload.status).to eql('cancelled')
      end

      it 'updates the move cancellation_reason' do
        expect(move.reload.cancellation_reason).to eql('rejected')
      end

      it 'updates the move cancellation_reason_comment' do
        expect(move.reload.cancellation_reason_comment).to eql('no room on the broom')
      end

      it 'updates the move rejection_reason' do
        expect(move.reload.rejection_reason).to eql('no_space_at_receiving_prison')
      end

      it 'creates a new move linked to the original move' do
        rebooked_move = move.reload.rebooked
        expect(rebooked_move.original_move).to eq(move)
      end

      it 'creates a move reject event' do
        expect(GenericEvent::MoveReject.count).to eq(1)
      end

      describe 'webhook and email notifications' do
        it 'calls the notifier when updating a person' do
          expect(Notifier).to have_received(:prepare_notifications).with(topic: move, action_name: 'update_status')
        end
      end
    end

    context 'with a bad request' do
      let(:reject_params) { nil }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'with a missing move_id' do
      let(:move_id) { 'foo-bar' }
      let(:detail_404) { "Couldn't find Move with 'id'=foo-bar" }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with validation errors' do
      context 'with a bad timestamp' do
        let(:reject_params) { { data: { type: 'reject', attributes: { timestamp: 'Foo-Bar', rejection_reason: 'no_space_at_receiving_prison' } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Invalid timestamp', 'detail' => 'Validation failed: Timestamp must be formatted as a valid ISO-8601 date-time' }] }
        end
      end

      context 'with a bad event type' do
        let(:reject_params) { { data: { type: 'Foo-bar', attributes: { timestamp: '2020-04-23T18:25:43.511Z', rejection_reason: 'no_space_at_receiving_prison' } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Invalid type', 'detail' => 'Validation failed: Type is not included in the list' }] }
        end
      end

      context 'with a bad rejection_reason' do
        let(:reject_params) { { data: { type: 'reject', attributes: { timestamp: '2020-04-23T18:25:43.511Z', rejection_reason: 'Yo Momma' } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Invalid rejection_reason', 'detail' => 'Validation failed: Rejection reason is not included in the list' }] }
        end
      end
    end
  end
end
