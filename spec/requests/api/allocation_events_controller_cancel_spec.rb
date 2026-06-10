# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::AllocationEventsController do
  let(:response_json) { JSON.parse(response.body) }

  describe 'POST /allocations/:id/cancel' do
    let(:schema) { load_yaml_schema('post_allocation_cancel_responses.yaml') }

    let(:access_token) { 'spoofed-token' }
    let(:headers) { { 'CONTENT_TYPE': content_type, 'Authorization': "Bearer #{access_token}" } }
    let(:content_type) { ApiController::CONTENT_TYPE }

    let(:allocation) { create(:allocation, :with_moves) }
    let(:move) { allocation.moves.first }
    let(:allocation_id) { allocation.id }
    let(:timestamp) { '2020-04-23T18:25:43.511Z' }
    let(:cancellation_reason) { 'made_in_error' }
    let(:cancel_params) do
      {
        data: {
          type: 'cancel',
          attributes: {
            timestamp:,
            cancellation_reason:,
            cancellation_reason_comment: 'FUBAR',
          },
        },
      }
    end

    before do
      allow(Notifier).to receive(:prepare_notifications)
      post "/api/v1/allocations/#{allocation_id}/cancel", params: cancel_params, headers:, as: :json
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 204'

      it 'updates the allocation cancellation reason' do
        expect(allocation.reload.cancellation_reason).to eq(cancellation_reason)
      end

      it 'updates the allocation cancellation reason comment' do
        expect(allocation.reload.cancellation_reason_comment).to eq('FUBAR')
      end

      it 'updates the allocation status' do
        expect(allocation.reload.status).to eql('cancelled')
      end

      it 'updates the allocation moves_count' do
        expect(allocation.reload.moves_count).to eq(0)
      end

      it 'updates the allocation moves status' do
        expect(allocation.reload.moves.pluck(:status).uniq).to contain_exactly('cancelled')
      end

      it 'updates the allocation moves cancellation reason' do
        expect(allocation.reload.moves.pluck(:cancellation_reason).uniq).to contain_exactly('other')
      end

      it 'updates the allocation moves cancellation reason comment' do
        expect(allocation.reload.moves.pluck(:cancellation_reason_comment).uniq).to contain_exactly('FUBAR')
      end

      describe 'webhook and email notifications' do
        it 'calls the move notifier when updating the status' do
          expect(Notifier).to have_received(:prepare_notifications).with(topic: move, action_name: 'update_status')
        end
      end
    end

    context 'with a bad request' do
      let(:cancel_params) { nil }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'with a missing id' do
      let(:allocation_id) { 'foo-bar' }
      let(:detail_404) { "Couldn't find Allocation with 'id'=foo-bar" }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with validation errors' do
      context 'with a bad timestamp' do
        let(:timestamp) { 'Foo-Bar' }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Invalid timestamp', 'detail' => 'Validation failed: Timestamp must be formatted as a valid ISO-8601 date-time' }] }
        end
      end

      context 'with a bad cancellation reason' do
        let(:cancellation_reason) { 'raining' }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Unprocessable content', 'detail' => 'Cancellation reason is not included in the list' }] }
        end
      end

      context 'with a missing cancellation_reason' do
        let(:cancellation_reason) { nil }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Unprocessable content', 'detail' => 'Cancellation reason is not included in the list' }] }
        end
      end
    end
  end
end
