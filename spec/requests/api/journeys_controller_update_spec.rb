# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::JourneysController do
  describe 'PATCH /moves/:move_id/journeys/:journey_id' do
    subject(:do_patch) do
      patch "/api/v1/moves/#{move_id}/journeys/#{journey_id}", params: journey_params, headers: headers, as: :json
      journey.reload
    end

    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body) }
    let(:from_location_id) { create(:location, suppliers: [supplier]).id }
    let(:to_location_id) { create(:location, suppliers: [supplier]).id }
    let(:move) { create(:move, from_location_id: from_location_id, supplier: supplier) }
    let(:move_id) { move.id }
    let(:journey) { create(:journey, move: move, supplier: supplier, billable: false, client_timestamp: '2020-05-04T08:00:00Z', from_location_id: from_location_id, to_location_id: to_location_id) }
    let(:journey_id) { journey.id }

    let(:timestamp) { '2020-05-04T12:12:12+01:00' }
    let(:billable) { true }

    let(:journey_params) do
      {
        data: {
          "type": 'journeys',
          "attributes": {
            "billable": billable,
            "timestamp": timestamp,
            "vehicle": { "id": '9876', "registration": 'XYZ' },
          },
        },
      }
    end

    context 'when successful' do
      let(:application) { create(:application, owner: supplier) }
      let(:access_token) { create(:access_token, application: application).token }
      let(:schema) { load_yaml_schema('get_journey_responses.yaml') }

      context 'when updating all attributes' do
        it_behaves_like 'an endpoint that responds with success 200' do
          before do
            do_patch
          end
        end

        it 'returns the correct data' do
          do_patch
          expect(response_json).to include_json(data: {
            "id": journey.id,
            "type": 'journeys',
            "attributes": {
              "billable": billable,
              "vehicle": { "id": '9876', "registration": 'XYZ' },
            },
          })
        end

        it 'updates the underlying journey billable' do
          do_patch
          expect(journey.billable).to be true
        end

        it 'updates the underlying journey vehicle' do
          do_patch
          expect(journey.vehicle).to eql('id' => '9876', 'registration' => 'XYZ')
        end

        it 'does not update the timestamp' do
          do_patch
          expect(journey.client_timestamp).to eql Time.zone.parse('2020-05-04T08:00:00Z')
        end

        it 'creates a JourneyUpdate generic event' do
          expect { do_patch }.to change(GenericEvent::JourneyUpdate, :count).by(1)
        end

        it 'sets the created_by from the header' do
          do_patch
          expect(GenericEvent.last.created_by).to eq('TEST_USER')
        end

        context 'when attempting to update the from_location or to_location' do
          let(:journey_params) do
            {
              data: {
                "type": 'journeys',
                "attributes": {
                  "billable": billable,
                  "timestamp": timestamp,
                  "vehicle": { "id": '9876', "registration": 'XYZ' },
                },
                "relationships": {
                  "from_location": {
                    "data": {
                      "id": to_location_id, # reversing from_location and to_location
                      "type": 'locations',
                    },
                  },
                  "to_location": {
                    "data": {
                      "id": from_location_id, # reversing from_location and to_location
                      "type": 'locations',
                    },
                  },
                },
              },
            }
          end

          it 'does not update from_location' do
            do_patch
            expect(journey.from_location.id).to eql(from_location_id)
          end

          it 'does not update to_location' do
            do_patch
            expect(journey.to_location.id).to eql(to_location_id)
          end
        end
      end

      context 'when only updating billable' do
        let(:journey_params) do
          {
            data: {
              "type": 'journeys',
              "attributes": {
                "billable": billable,
                "timestamp": timestamp,
              },
            },
          }
        end

        it 'updates the underlying journey billable' do
          do_patch
          expect(journey.billable).to be true
        end

        it 'does not update the underlying journey vehicle' do
          do_patch
          expect(journey.vehicle).to eql('id' => '12345678ABC', 'registration' => 'AB12 CDE')
        end
      end

      context 'when only updating the vehicle' do
        let(:journey_params) do
          {
            data: {
              "type": 'journeys',
              "attributes": {
                "vehicle": { "id": '9876', "registration": 'XYZ' },
                "timestamp": timestamp,
              },
            },
          }
        end

        it 'does not update the underlying journey billable' do
          do_patch
          expect(journey.billable).to be false
        end

        it 'does update the underlying journey vehicle' do
          do_patch
          expect(journey.vehicle).to eql('id' => '9876', 'registration' => 'XYZ')
        end
      end
    end

    context 'when unsuccessful' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }

      context 'with a bad request' do
        let(:journey_params) { nil }

        it_behaves_like 'an endpoint that responds with error 400' do
          before do
            do_patch
          end
        end
      end

      context 'with an invalid timestamp' do
        let(:timestamp) { 'foo-bar' }

        it_behaves_like 'an endpoint that responds with error 422' do
          before do
            do_patch
          end

          let(:errors_422) do
            [{ 'title' => 'Invalid timestamp',
               'detail' => 'Validation failed: Timestamp must be formatted as a valid ISO-8601 date-time' }]
          end
        end
      end

      context 'with an invalid billable' do
        let(:billable) { 'foo-bar' }

        it_behaves_like 'an endpoint that responds with error 422' do
          before do
            do_patch
          end

          let(:errors_422) do
            [{ 'title' => 'Invalid billable',
               'detail' => 'Validation failed: Billable is not included in the list' }]
          end
        end
      end

      context 'when the move_id is not found' do
        let(:move_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find Move with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404' do
          before do
            do_patch
          end
        end
      end

      context 'when the journey_id is not found' do
        let(:journey_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find Journey with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404' do
          before do
            do_patch
          end
        end
      end
    end
  end
end
