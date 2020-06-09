# frozen_string_literal: true

# TODO: remove file completely when allocation `events` endpoint is no longer in use
require 'rails_helper'

RSpec.describe Api::V1::AllocationEventsController do
  let(:response_json) { JSON.parse(response.body) }

  describe 'POST /allocations/:id/events' do
    let(:schema) { load_yaml_schema('post_allocation_events_responses.yaml') }

    let(:supplier) { create(:supplier) }
    let(:application) { create(:application, owner_id: supplier.id) }
    let(:access_token) { create(:access_token, application: application).token }
    let(:headers) { { 'CONTENT_TYPE': content_type, 'Authorization': "Bearer #{access_token}" } }
    let(:content_type) { ApiController::CONTENT_TYPE }

    let(:allocation) { create(:allocation, :with_moves) }
    let(:move) { allocation.moves.first }
    let(:allocation_id) { allocation.id }
    let(:allocation_event_params) do
      {
        data: {
          type: 'events',
          attributes: {
            timestamp: '2020-04-23T18:25:43.511Z',
            event_name: 'cancel',
          },
        },
      }
    end

    before do
      allow(Notifier).to receive(:prepare_notifications)
      post "/api/v1/allocations/#{allocation_id}/events", params: allocation_event_params, headers: headers, as: :json
    end

    describe 'Cancel event' do
      context 'when successful' do
        it_behaves_like 'an endpoint that responds with success 201'

        it 'updates the allocation status' do
          expect(allocation.reload.status).to eql('cancelled')
        end

        it 'updates the allocation moves_count' do
          expect(allocation.reload.moves_count).to eq(0)
        end

        it 'updates the allocation moves status' do
          expect(allocation.reload.moves.pluck(:status).uniq).to contain_exactly('cancelled')
        end

        describe 'webhook and email notifications' do
          it 'calls the move notifier when updating the status' do
            expect(Notifier).to have_received(:prepare_notifications).with(topic: move, action_name: 'update_status')
          end
        end
      end
    end

    context 'with a bad request' do
      let(:allocation_event_params) { nil }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'when not authorized' do
      let(:access_token) { 'foo-bar' }
      let(:detail_401) { 'Token expired or invalid' }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with a missing allocation_id' do
      let(:allocation_id) { 'foo-bar' }
      let(:detail_404) { "Couldn't find Allocation with 'id'=foo-bar" }

      it_behaves_like 'an endpoint that responds with error 404'

      it 'does not call the move notifier' do
        expect(Notifier).not_to have_received(:prepare_notifications)
      end
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end

    context 'with validation errors' do
      # TODO: add validation tests once the Event model is finalised
    end
  end
end
