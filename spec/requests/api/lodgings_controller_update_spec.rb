# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::LodgingsController do
  describe 'PATCH /moves/:move_id/lodgings/:lodging_id' do
    subject(:do_patch) do
      patch "/api/moves/#{move.id}/lodgings/#{lodging.id}", params:, headers:, as: :json
    end

    let(:headers) do
      {
        'CONTENT_TYPE': content_type,
        'Accept': 'application/vnd.api+json; version=2',
        'Authorization' => "Bearer #{access_token}",
        'X-Current-User' => 'TEST_USER',
        'Idempotency-Key' => SecureRandom.uuid,
      }
    end

    let(:response_json) { JSON.parse(response.body) }
    let(:schema) { load_yaml_schema('patch_lodgings_responses.yaml') }
    let(:supplier) { create(:supplier) }
    let(:access_token) { 'spoofed-token' }
    let(:content_type) { ApiController::CONTENT_TYPE }
    let(:location) { create(:location, suppliers: [supplier]) }
    let(:other_location) { create(:location, suppliers: [supplier]) }
    let(:move) { create(:move, supplier:) }
    let(:start_date) { '2020-05-04' }
    let(:end_date) { '2020-05-05' }
    let!(:lodging) { create(:lodging, move:, location:, start_date:, end_date:) }

    before do
      allow(Notifier).to receive(:prepare_notifications)
    end

    context 'with valid end_date param' do
      let(:data) do
        {
          id: lodging.id,
          type: 'lodgings',
          attributes: {
            start_date: '2020-05-04',
            end_date: '2020-05-06',
          },
          relationships: {
            location: {
              data: {
                type: 'locations',
                id: location.id,
              },
            },
          },
        }
      end

      let(:params) do
        {
          data: {
            id: lodging.id,
            type: 'lodgings',
            attributes: {
              end_date: '2020-05-06',
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 200' do
        before { do_patch }
      end

      it 'returns the correct data' do
        do_patch
        expect(response_json).to include_json(data:)
      end

      it 'updates the lodging' do
        do_patch
        expect(lodging.reload.end_date).to eq('2020-05-06')
      end

      it 'creates a LodgingUpdate generic event' do
        expect { do_patch }.to change(GenericEvent::LodgingUpdate, :count).by(1)
      end

      it 'sets the created by on the GenericEvent' do
        do_patch
        expect(GenericEvent.last.created_by).to eq('TEST_USER')
      end

      it 'sends a notification' do
        do_patch
        expect(Notifier).to have_received(:prepare_notifications).with(topic: lodging, action_name: 'update')
      end

      context 'when requested by a supplier' do
        let(:application) { create(:application, owner: supplier) }
        let(:access_token) { create(:access_token, application:).token }

        it_behaves_like 'an endpoint that responds with error 401' do
          let(:detail_401) { 'Not authorized' }
          let(:schema) { load_yaml_schema('error_responses.yaml') }

          before { do_patch }
        end
      end

      context 'with other lodgings' do
        let!(:cancelled_lodging) { create(:lodging, move:, location:, start_date: '2020-05-05', end_date: '2020-05-06', status: :cancelled) }
        let!(:lodging2) { create(:lodging, move:, location:, start_date: '2020-05-03', end_date: '2020-05-04') }
        let!(:lodging3) { create(:lodging, move:, location:, start_date: '2020-05-05', end_date: '2020-05-06') }
        let!(:lodging4) { create(:lodging, move:, location:, start_date: '2020-05-06', end_date: '2020-05-08') }

        it 'updates the lodging' do
          do_patch
          expect(lodging.reload.attributes).to include({
            'start_date' => '2020-05-04',
            'end_date' => '2020-05-06',
          })
        end

        it 'does not update the earlier lodging' do
          do_patch
          expect(lodging2.reload.attributes).to include({
            'start_date' => '2020-05-03',
            'end_date' => '2020-05-04',
          })
        end

        it 'does not update the cancelled lodging' do
          do_patch
          expect(cancelled_lodging.reload.attributes).to include({
            'start_date' => '2020-05-05',
            'end_date' => '2020-05-06',
          })
        end

        it 'updates the next lodging' do
          do_patch
          expect(lodging3.reload.attributes).to include({
            'start_date' => '2020-05-06',
            'end_date' => '2020-05-07',
          })
        end

        it 'updates the last lodging' do
          do_patch
          expect(lodging4.reload.attributes).to include({
            'start_date' => '2020-05-07',
            'end_date' => '2020-05-09',
          })
        end

        it 'adds an event for each' do
          update_event_count = GenericEvent::LodgingUpdate.count
          do_patch
          expect(GenericEvent::LodgingUpdate.count).to eq(update_event_count + 3)

          # Get all event details from the newly created events
          new_events = GenericEvent::LodgingUpdate.order(:created_at).last(3)
          event_details = new_events.map(&:details)

          # Verify all expected event details are present (order independent)
          expect(event_details).to include(
            {
              'old_start_date' => '2020-05-05',
              'start_date' => '2020-05-06',
              'old_end_date' => '2020-05-06',
              'end_date' => '2020-05-07',
            },
            {
              'old_start_date' => '2020-05-06',
              'start_date' => '2020-05-07',
              'old_end_date' => '2020-05-08',
              'end_date' => '2020-05-09',
            },
            {
              'old_end_date' => '2020-05-05',
              'end_date' => '2020-05-06',
            },
          )
        end

        it 'sends notifications for the other lodgings' do
          expect(Notifier).to receive(:prepare_notifications).with(topic: lodging3, action_name: 'update').ordered
          expect(Notifier).to receive(:prepare_notifications).with(topic: lodging4, action_name: 'update').ordered
          expect(Notifier).to receive(:prepare_notifications).with(topic: lodging, action_name: 'update').ordered
          do_patch
        end
      end
    end

    context 'with valid location param' do
      let(:data) do
        {
          id: lodging.id,
          type: 'lodgings',
          attributes: {
            start_date: '2020-05-04',
            end_date: '2020-05-05',
          },
          relationships: {
            location: {
              data: {
                type: 'locations',
                id: other_location.id,
              },
            },
          },
        }
      end

      let(:params) do
        {
          data: {
            id: lodging.id,
            type: 'lodgings',
            relationships: {
              location: {
                data: {
                  type: 'locations',
                  id: other_location.id,
                },
              },
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 200' do
        before { do_patch }
      end

      it 'returns the correct data' do
        do_patch
        expect(response_json).to include_json(data:)
      end

      it 'updates the lodging' do
        do_patch
        expect(lodging.reload.location_id).to eq(other_location.id)
      end

      it 'creates a LodgingUpdate generic event' do
        expect { do_patch }.to change(GenericEvent::LodgingUpdate, :count).by(1)
      end

      it 'sets the created by on the GenericEvent' do
        do_patch
        expect(GenericEvent.last.created_by).to eq('TEST_USER')
      end

      it 'sends a notification' do
        do_patch
        expect(Notifier).to have_received(:prepare_notifications).with(topic: lodging, action_name: 'update')
      end

      context 'when requested by a supplier' do
        let(:application) { create(:application, owner: supplier) }
        let(:access_token) { create(:access_token, application:).token }

        it_behaves_like 'an endpoint that responds with error 401' do
          let(:detail_401) { 'Not authorized' }
          let(:schema) { load_yaml_schema('error_responses.yaml') }

          before { do_patch }
        end
      end
    end

    context 'with bad params' do
      let(:params) do
        {
          data: {
            id: lodging.id,
            type: 'lodgings',
            attributes: {
              end_date: '2020-99-99',
            },
          },
        }
      end

      let(:schema) { load_yaml_schema('error_responses.yaml') }

      it_behaves_like 'an endpoint that responds with error 422' do
        before { do_patch }

        let(:errors_422) do
          [{ 'title' => 'Invalid end_date',
             'detail' => 'Validation failed: End date must be formatted as a valid ISO-8601 date' }]
        end
      end

      it 'does not create an event' do
        expect { do_patch }.not_to change(GenericEvent::LodgingUpdate, :count)
      end
    end
  end
end
