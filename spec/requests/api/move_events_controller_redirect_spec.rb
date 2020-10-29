# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MoveEventsController do
  describe 'POST /moves/:move_id/redirects' do
    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body) }
    let(:schema) { load_yaml_schema('post_move_events_responses.yaml') }
    let(:from_location) { create(:location, suppliers: [supplier]) }
    let(:move) { create(:move, :prison_transfer, from_location: from_location) }
    let(:move_id) { move.id }
    let(:new_location) { create(:location) }
    let(:attributes) do
      {
        timestamp: '2020-04-23T18:25:43.511Z',
        notes: 'requested by PMU',
      }
    end
    let(:redirect_params) do
      {
        data: {
          type: 'redirects',
          attributes: attributes,
          relationships: {
            to_location: { data: { type: 'locations', id: new_location.id } },
          },
        },
      }
    end

    before do
      allow(Notifier).to receive(:prepare_notifications)
      post "/api/v1/moves/#{move_id}/redirects", params: redirect_params, headers: headers, as: :json
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 204'

      it 'updates the move to_location' do
        expect(move.reload.to_location).to eql(new_location)
      end

      describe 'webhook and email notifications' do
        it 'calls the notifier when updating a person' do
          expect(Notifier).to have_received(:prepare_notifications).with(topic: move, action_name: 'update')
        end
      end
    end

    context 'with an updated move type corresponding to the new location' do
      let(:new_location) { create(:location, :court) }
      let(:attributes) do
        {
          timestamp: '2020-04-23T18:25:43.511Z',
          notes: 'requested by PMU',
          move_type: 'court_appearance',
        }
      end

      it 'updates the move to_location' do
        expect(move.reload.to_location).to eql(new_location)
      end

      it 'updates the move move_type' do
        expect { move.reload }.to change(move, :move_type).from('prison_transfer').to('court_appearance')
      end

      it 'creates a move redirect event' do
        expect(GenericEvent::MoveRedirect.count).to eq(1)
      end
    end

    context 'with a video remand hearing' do
      let(:move) { create(:move, :video_remand) }

      it 'populates the move to_location' do
        expect { move.reload }.to change(move, :to_location).from(nil).to(new_location)
      end
    end

    context 'with a hospital move' do
      let(:move) { create(:move, :hospital) }
      let(:new_location) { create(:location, :high_security_hospital) }

      it 'updates the move to_location' do
        expect(move.reload.to_location).to eql(new_location)
      end
    end

    context 'with a bad request' do
      let(:redirect_params) { nil }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'with a missing move_id' do
      let(:move_id) { 'foo-bar' }
      let(:detail_404) { "Couldn't find Move with 'id'=foo-bar" }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with validation errors' do
      context 'with a bad timestamp' do
        let(:redirect_params) do
          { data: { type: 'redirects',
                    attributes: { timestamp: 'Foo-Bar' },
                    relationships: {
                      to_location: { data: { type: 'locations', id: new_location.id } },
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
        let(:redirect_params) { { data: { type: 'Foo-bar', attributes: { timestamp: '2020-04-23T18:25:43.511Z' } } } }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{
              'title' => 'Invalid type',
              'detail' => 'Validation failed: Type is not included in the list',
            }]
          end
        end
      end

      context 'with a non-existent to_location_id' do
        let(:redirect_params) do
          {
            data: {
              type: 'redirects',
              attributes: { timestamp: '2020-04-23T18:25:43.511Z' },
              relationships: { to_location: { data: { type: 'locations', id: 'atlantis' } } },
            },
          }
        end

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{
              'title' => 'Invalid to_location_id',
              'detail' => 'Validation failed: To location was not found',
            }]
          end
        end
      end

      context 'with a redirection to an invalid location for the move type' do
        let(:move) { create(:move, :hospital) }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{
              'title' => 'Unprocessable entity',
              'detail' => 'To location must be a high security hospital location for hospital move',
            }]
          end
        end
      end
    end
  end
end
