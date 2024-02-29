# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::LodgingsController do
  describe 'POST /moves/:move_id/lodgings' do
    subject(:do_post) do
      post "/api/moves/#{move_id}/lodgings", params:, headers:, as: :json
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
    let(:schema) { load_yaml_schema('post_moves_responses.yaml', version: 'v2') }
    let(:supplier) { create(:supplier) }
    let(:access_token) { 'spoofed-token' }
    let(:content_type) { ApiController::CONTENT_TYPE }
    let(:location) { create(:location, suppliers: [supplier]) }
    let(:location_id) { location.id }
    let(:move) { create(:move, supplier:) }
    let(:move_id) { move.id }
    let(:start_date) { '2020-05-04' }
    let(:end_date) { '2020-05-05' }

    let(:params) do
      {
        data: {
          type: 'lodgings',
          attributes: {
            start_date:,
            end_date:,
          },
          relationships: {
            location: {
              data: {
                id: location_id,
                type: 'locations',
              },
            },
          },
        },
      }
    end

    context 'when successful' do
      let(:data) do
        {
          id: Lodging.find_by(start_date: '2020-05-04')&.id,
          type: 'lodgings',
          attributes: {
            status: 'proposed',
            start_date: '2020-05-04',
            end_date: '2020-05-05',
          },
          relationships: {
            location: {
              data: {
                id: location.id,
                type: 'locations',
              },
            },
          },
        }
      end

      let(:schema) { load_yaml_schema('post_lodgings_responses.yaml') }

      it_behaves_like 'an endpoint that responds with success 201' do
        before { do_post }
      end

      it 'returns the correct data' do
        do_post
        expect(response_json).to include_json(data:)
      end

      it 'creates a LodgingCreate generic event' do
        expect { do_post }.to change(GenericEvent::LodgingCreate, :count).by(1)
      end

      it 'sets the created by on the GenericEvent' do
        do_post
        expect(GenericEvent.last.created_by).to eq('TEST_USER')
      end
    end

    context 'when unsuccessful' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }

      context 'when requested by a supplier' do
        let(:application) { create(:application, owner: supplier) }
        let(:access_token) { create(:access_token, application:).token }

        it_behaves_like 'an endpoint that responds with error 401' do
          let(:detail_401) { 'You are not authorized to access this page.' }

          before { do_post }
        end
      end

      context 'with an invalid start date' do
        let(:start_date) { '9999-A1-02' }

        it_behaves_like 'an endpoint that responds with error 422' do
          before { do_post }

          let(:errors_422) do
            [{ 'title' => 'Invalid start_date',
               'detail' => 'Validation failed: Start date must be formatted as a valid ISO-8601 date' }]
          end
        end
      end

      context 'with a bad request' do
        let(:params) { nil }

        it_behaves_like 'an endpoint that responds with error 400' do
          before { do_post }
        end
      end

      context 'when the move_id is not found' do
        let(:move_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find Move with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404' do
          before do
            do_post
          end
        end
      end

      context 'with a reference to a missing relationship' do
        let(:location_id) { 'foo-bar' }

        it_behaves_like 'an endpoint that responds with error 422' do
          before { do_post }

          let(:errors_422) do
            [{ 'title' => 'Invalid location',
               'detail' => 'Validation failed: Location reference was not found id=foo-bar' }]
          end
        end
      end
    end
  end
end
