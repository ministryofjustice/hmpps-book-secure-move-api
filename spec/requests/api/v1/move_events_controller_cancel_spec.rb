# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MoveEventsController do
  let(:response_json) { JSON.parse(response.body) }

  describe 'POST /moves/:move_id/cancel' do
    let(:schema) { load_yaml_schema('post_move_cancel_responses.yaml') }

    let(:supplier) { create(:supplier) }
    let(:application) { create(:application, owner_id: supplier.id) }
    let(:access_token) { create(:access_token, application: application).token }
    let(:headers) { { 'CONTENT_TYPE': content_type, 'Authorization': "Bearer #{access_token}" } }
    let(:content_type) { ApiController::CONTENT_TYPE }

    let(:move) { create(:move) }
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
      allow(Notifier).to receive(:prepare_notifications)
      post "/api/v1/moves/#{move_id}/cancel", params: cancel_params, headers: headers, as: :json
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 204'

      it 'updates the move status' do
        expect(move.reload.status).to eql('cancelled')
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

    context 'when not authorized' do
      let(:access_token) { 'foo-bar' }
      let(:detail_401) { 'Token expired or invalid' }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with a missing move_id' do
      let(:move_id) { 'foo-bar' }
      let(:detail_404) { "Couldn't find Move with 'id'=foo-bar" }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end

    context 'with validation errors' do
      context 'with a bad timestamp' do
        let(:cancel_params) { { data: { type: 'cancel', attributes: { timestamp: 'Foo-Bar' } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Invalid timestamp', 'detail' => 'Validation failed: Timestamp must be formatted as a valid ISO-8601 date-time' }] }
        end
      end

      context 'with a bad event type' do
        let(:cancel_params) { { data: { type: 'Foo-bar', attributes: { timestamp: '2020-04-23T18:25:43.511Z' } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Invalid type', 'detail' => 'Validation failed: Type is not included in the list' }] }
        end
      end
    end
  end
end
