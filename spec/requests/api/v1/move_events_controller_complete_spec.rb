# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MoveEventsController do
  let(:response_json) { JSON.parse(response.body) }

  describe 'POST /moves/:move_id/complete' do
    let(:schema) { load_yaml_schema('post_move_events_responses.yaml') }

    let(:supplier) { create(:supplier) }
    let(:application) { create(:application, owner_id: supplier.id) }
    let(:access_token) { create(:access_token, application: application).token }
    let(:headers) { { 'CONTENT_TYPE': content_type, 'Authorization': "Bearer #{access_token}", 'IDEMPOTENCY_KEY': current_idempotency_key } }
    let(:content_type) { ApiController::CONTENT_TYPE }
    let(:previous_idempotency_key) { '1234' }
    let(:current_idempotency_key) { '5678' }
    let(:mock_redis) { MockRedis.new }
    let(:move) { create(:move) }
    let(:move_id) { move.id }
    let(:new_location) { create(:location) }
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
      allow(Redis).to receive(:new) { mock_redis }
      allow(ENV).to receive(:fetch).with('REDIS_URL', nil).and_return('http://some.where')
      mock_redis.set(previous_idempotency_key, 'T')
      post "/api/v1/moves/#{move_id}/complete", params: complete_params, headers: headers, as: :json
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 204'

      it 'updates the move status' do
        expect(move.reload.status).to eql('completed')
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

    context 'with a reference to a missing relationship' do
      let(:new_location) { build(:location) }
      let(:detail_404) { "Couldn't find Location without an ID" }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with a non-idempotent request' do
      let(:current_idempotency_key) { previous_idempotency_key }
      let(:detail_409) { 'Idempotence::ConflictError: conflicting idempotency key: 1234' }

      it_behaves_like 'an endpoint that responds with error 409'
    end

    context 'with a blank idempotency_key' do
      let(:current_idempotency_key) { nil }

      it_behaves_like 'an endpoint that responds with error 400' do
        let(:errors_400) do
          [{
            'title' => 'Bad request',
            'detail' => 'idempotency key is required',
          }]
        end
      end
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
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
