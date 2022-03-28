# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MoveEventsController do
  describe 'POST /moves/:move_id/lockouts' do
    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body) }
    let(:schema) { load_yaml_schema('post_move_events_responses.yaml') }
    let(:from_location) { create(:location, suppliers: [supplier]) }
    let(:move) { create(:move, from_location: from_location) }
    let(:move_id) { move.id }
    let(:lockout_location) { create(:location) }
    let(:lockout_params) do
      {
        data: {
          type: 'lockouts',
          attributes: {
            timestamp: '2020-04-23T18:25:43.511Z',
            notes: 'delayed by van breakdown',
          },
          relationships: {
            from_location: { data: { type: 'locations', id: lockout_location.id } },
          },
        },
      }
    end

    before do
      allow(Notifier).to receive(:prepare_notifications)
      post "/api/v1/moves/#{move_id}/lockouts", params: lockout_params, headers: headers, as: :json
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 204'

      it 'does not update the move status' do
        expect(move.reload.status).to eql('requested')
      end

      it 'creates a move lockout event' do
        expect(GenericEvent::MoveLockout.count).to eq(1)
      end

      describe 'webhook and email notifications' do
        it 'calls the notifier when updating a person' do
          expect(Notifier).to have_received(:prepare_notifications)
        end
      end
    end

    context 'with a bad request' do
      let(:lockout_params) { nil }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'with a missing move_id' do
      let(:move_id) { 'foo-bar' }
      let(:detail_404) { "Couldn't find Move with 'id'=foo-bar" }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with validation errors' do
      context 'with a bad timestamp' do
        let(:lockout_params) do
          { data: { type: 'lockouts',
                    attributes: { timestamp: 'Foo-Bar' },
                    relationships: {
                      from_location: { data: { type: 'locations', id: lockout_location.id } },
                    } } }
        end

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{
              'title' => 'Invalid timestamp',
              'detail' => 'Validation failed: Timestamp must be formatted as a valid ISO-8601 date-time',
            }]
          end
        end
      end

      context 'with a bad event type' do
        let(:lockout_params) { { data: { type: 'Foo-bar', attributes: { timestamp: '2020-04-23T18:25:43.511Z' } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{
              'title' => 'Invalid type',
              'detail' => 'Validation failed: Type is not included in the list',
            }]
          end
        end
      end

      context 'with a non-existent from_location_id' do
        let(:lockout_params) do
          {
            data: {
              type: 'lockouts',
              attributes: { timestamp: '2020-04-23T18:25:43.511Z' },
              relationships: { from_location: { data: { type: 'locations', id: 'atlantis' } } },
            },
          }
        end

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{
              'title' => 'Invalid from_location_id',
              'detail' => 'Validation failed: From location was not found',
            }]
          end
        end
      end
    end
  end
end
