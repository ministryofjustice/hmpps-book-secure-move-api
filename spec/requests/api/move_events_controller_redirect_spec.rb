# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MoveEventsController do
  describe 'POST /moves/:move_id/redirects' do
    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body) }
    let(:schema) { load_yaml_schema('post_move_events_responses.yaml') }
    let(:from_location) { create(:location, suppliers: [supplier]) }
    let(:move) { create(:move, :prison_transfer, from_location:) }
    let(:move_id) { move.id }
    let(:new_location) { create(:location, :prison) }
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
          attributes:,
          relationships: {
            to_location: { data: { type: 'locations', id: new_location.id } },
          },
        },
      }
    end
    let(:before_post) { nil }

    let(:envs) { { FEATURE_FLAG_CROSS_SUPPLIER_NOTIFICATIONS_SUPPLIERS: 'geoamey,serco' } }

    around do |example|
      ClimateControl.modify(**envs) do
        example.run
      end
    end

    before do
      allow(Notifier).to receive(:prepare_notifications)
      before_post
      post "/api/v1/moves/#{move_id}/redirects", params: redirect_params, headers:, as: :json
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

    context 'with a lockout move with to_location the same as from_location' do
      let(:new_location) { move.from_location }
      let(:before_post) { create(:event_move_lockout, eventable: move) }

      it_behaves_like 'an endpoint that responds with success 204'

      it 'updates the move to_location' do
        expect(move.reload.to_location).to eql(new_location)
      end

      it 'creates a move redirect event' do
        expect(GenericEvent::MoveRedirect.count).to eq(1)
      end
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

      context 'with a redirection to an invalid location for the current move type' do
        let(:move) { create(:move, :hospital) }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{
              'title' => 'Unprocessable content',
              'detail' => 'To location must be a hospital or high security hospital location for hospital move',
              'source' => { 'pointer' => '/data/attributes/to_location' },
              'code' => 'invalid_location',
            }]
          end
        end
      end

      context 'with a redirection to an invalid location for the new move type' do
        let(:attributes) do
          {
            timestamp: '2020-04-23T18:25:43.511Z',
            notes: 'requested by PMU',
            move_type: 'hospital',
          }
        end

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{
              'title' => 'Unprocessable content',
              'detail' => 'To location must be a hospital or high security hospital location for hospital move',
              'source' => { 'pointer' => '/data/attributes/to_location' },
              'code' => 'invalid_location',
            }]
          end
        end
      end

      context 'with a redirection to an inactive location' do
        let(:new_location) { create(:location, :inactive) }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{
              'title' => 'Unprocessable content',
              'detail' => 'To location must be an active location',
              'source' => { 'pointer' => '/data/attributes/to_location' },
              'code' => 'inactive_location',
            }]
          end
        end
      end

      context 'with a to_location the same as from_location' do
        let(:new_location) { move.from_location }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{
              'title' => 'Unprocessable content',
              'detail' => 'To location id should be different to the from location',
            }]
          end
        end
      end

      context 'when it becomes a cross-supplier move' do
        let(:initial_supplier) { create(:supplier, :serco) }
        let(:receiving_supplier) { create(:supplier, :geoamey) }
        let(:from_location) { create(:location, :court, suppliers: [initial_supplier]) }
        let(:old_to_location) { create(:location, :court, suppliers: [initial_supplier]) }
        let(:new_location) { create(:location, :court, suppliers: [receiving_supplier]) }
        let(:move) { create(:move, :court_appearance, from_location:, to_location: old_to_location) }

        let(:before_post) do
          # Pre-existing events to make sure we don't send new notifications for all of them
          create(
            :event_move_redirect,
            eventable: move,
            occurred_at: '2019-01-01',
            recorded_at: '2019-01-01',
            details: {
              to_location_id: new_location.id,
            },
          )
          create(
            :event_move_redirect,
            eventable: move,
            occurred_at: '2019-01-02',
            recorded_at: '2019-01-02',
            details: {
              to_location_id: old_to_location.id,
            },
          )
        end

        it 'sends a cross_supplier_move_add notification to the receiving supplier' do
          expect(Notifier).to have_received(:prepare_notifications).once.with(topic: move, action_name: 'cross_supplier_add')
        end
      end

      context 'when it ceases to be a cross-supplier move' do
        let(:initial_supplier) { create(:supplier, :serco) }
        let(:receiving_supplier) { create(:supplier, :geoamey) }
        let(:from_location) { create(:location, :court, suppliers: [initial_supplier]) }
        let(:old_to_location) { create(:location, :court, suppliers: [receiving_supplier]) }
        let(:new_location) { create(:location, :court, suppliers: [initial_supplier]) }
        let(:move) { create(:move, :court_appearance, from_location:, to_location: old_to_location) }

        let(:before_post) do
          # Pre-existing events to make sure we don't send new notifications for all of them
          create(
            :event_move_redirect,
            eventable: move,
            occurred_at: '2019-01-01',
            recorded_at: '2019-01-01',
            details: {
              to_location_id: new_location.id,
            },
          )
          create(
            :event_move_redirect,
            eventable: move,
            occurred_at: '2019-01-02',
            recorded_at: '2019-01-02',
            details: {
              to_location_id: old_to_location.id,
            },
          )
        end

        it 'sends a cross_supplier_move_remove notification to the receiving supplier' do
          expect(Notifier).to have_received(:prepare_notifications).once.with(topic: move, action_name: 'cross_supplier_remove')
        end
      end
    end
  end
end
