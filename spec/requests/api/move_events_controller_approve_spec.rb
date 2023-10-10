# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MoveEventsController do
  describe 'POST /moves/:move_id/approve' do
    include_context 'with supplier with spoofed access token'

    let(:schema) { load_yaml_schema('post_move_events_responses.yaml') }
    let(:response_json) { JSON.parse(response.body) }
    let(:move) { create(:move, :proposed, from_location: create(:location, suppliers: [supplier]), supplier:) }
    let(:approved_date) { move.date + 1.day }
    let(:move_id) { move.id }
    let(:approve_params) do
      {
        data: {
          type: 'approves',
          attributes: {
            timestamp: '2020-04-23T18:25:43.511Z',
            date: approved_date,
            create_in_nomis: 'true',
          },
        },
      }
    end

    before do
      allow(Allocations::CreateInNomis).to receive(:call)
      allow(Notifier).to receive(:prepare_notifications)
      post "/api/v1/moves/#{move_id}/approve", params: approve_params, headers:, as: :json
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 204'

      it 'updates the move status' do
        expect(move.reload.status).to eql('requested')
      end

      it 'updates the move date' do
        expect(move.reload.date).to eql(approved_date)
      end

      it 'creates a prison transfer event in Nomis' do
        expect(Allocations::CreateInNomis).to have_received(:call).with(move)
      end

      it 'creates a move approve event' do
        expect(GenericEvent::MoveApprove.count).to eq(1)
      end

      describe 'webhook and email notifications' do
        it 'calls the notifier' do
          expect(Notifier).to have_received(:prepare_notifications).with(topic: move, action_name: 'update_status')
        end
      end
    end

    context 'with a bad request' do
      let(:approve_params) { nil }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'with a missing move_id' do
      let(:move_id) { 'foo-bar' }
      let(:detail_404) { "Couldn't find Move with 'id'=foo-bar" }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with validation errors' do
      context 'with a bad timestamp' do
        let(:approve_params) { { data: { type: 'approve', attributes: { timestamp: 'Foo-Bar', date: approved_date } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Invalid timestamp', 'detail' => 'Validation failed: Timestamp must be formatted as a valid ISO-8601 date-time' }] }
        end
      end

      context 'with a bad date' do
        let(:approve_params) { { data: { type: 'approve', attributes: { timestamp: '2020-04-23T18:25:43.511Z', date: 'Foo-Bar' } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Invalid date', 'detail' => 'Validation failed: Date is not a valid date.' }] }
        end
      end

      context 'with a missing date' do
        let(:approve_params) { { data: { type: 'approve', attributes: { timestamp: '2020-04-23T18:25:43.511Z' } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Invalid date', 'detail' => "Validation failed: Date can't be blank" }] }
        end
      end

      context 'with a bad event type' do
        let(:approve_params) { { data: { type: 'Foo-bar', attributes: { timestamp: '2020-04-23T18:25:43.511Z', date: approved_date } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) { [{ 'title' => 'Invalid type', 'detail' => 'Validation failed: Type is not included in the list' }] }
        end
      end
    end
  end
end
