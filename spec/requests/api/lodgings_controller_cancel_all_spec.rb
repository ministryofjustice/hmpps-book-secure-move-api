# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::LodgingsController do
  describe 'POST /moves/:move_id/lodgings/cancel' do
    subject(:do_post) do
      post "/api/moves/#{move_id}/lodgings/cancel", headers:, params:, as: :json
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
    let(:move) { create(:move, supplier:, date: '2024-01-01') }
    let(:move_id) { move.id }
    let(:cancellation_reason) { 'other' }
    let(:cancellation_reason_comment) { 'Cancelled on a whim' }
    let!(:lodging1) { create(:lodging, move:, status: :cancelled) }
    let!(:lodging2) { create(:lodging, move:, start_date: '2024-01-01', end_date: '2024-01-02') }
    let!(:lodging3) { create(:lodging, move:, start_date: '2024-01-02', end_date: '2024-01-03') }

    let(:params) do
      {
        data: {
          type: 'lodgings',
          attributes: {
            cancellation_reason:,
            cancellation_reason_comment:,
          },
        },
      }
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 204' do
        before { do_post }
      end

      it 'returns a blank body' do
        do_post
        expect(response.body).to be_empty
      end

      it 'creates a LodgingCancel generic event for each lodging' do
        expect { do_post }.to change(GenericEvent::LodgingCancel, :count).by(2)
      end

      it 'sets the right fields on the GenericEvent' do
        do_post
        expect(GenericEvent.order(:created_at).last.attributes.slice('created_by', 'details')).to eq({
          'created_by' => 'TEST_USER',
          'details' => {
            'start_date' => '2024-01-02',
            'end_date' => '2024-01-03',
            'cancellation_reason' => 'other',
            'cancellation_reason_comment' => 'Cancelled on a whim',
            'location_id' => lodging3.location.id,
          },
        })
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

      context 'with an invalid cancellation reason' do
        let(:cancellation_reason) { 'no_reason' }

        it_behaves_like 'an endpoint that responds with error 422' do
          before { do_post }

          let(:errors_422) do
            [{ 'title' => 'Unprocessable entity',
               'detail' => 'Cancellation reason is not included in the list' }]
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
    end
  end
end
