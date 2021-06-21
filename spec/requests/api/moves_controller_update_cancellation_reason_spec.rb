# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Api::MovesController do
  let(:response_json) { JSON.parse(response.body) }

  describe 'PATCH /moves/:move_id' do
    let(:supplier) { create(:supplier) }
    let(:access_token) { 'spoofed-token' }
    let(:headers) { { 'CONTENT_TYPE': content_type, 'Authorization': "Bearer #{access_token}" } }
    let(:content_type) { ApiController::CONTENT_TYPE }

    let(:schema) { load_yaml_schema('patch_move_responses.yaml') }
    let(:from_location_id) { create(:location, suppliers: [supplier]).id }
    let(:to_location_id) { create(:location, suppliers: [supplier]).id }
    let(:move) { create(:move, status: initial_status, date: date, date_from: date_from, from_location_id: from_location_id, to_location_id: to_location_id) }
    let(:move_id) { move.id }
    let(:cancellation_reason_comment) { nil }

    let(:move_params) do
      {
        data: {
          type: 'moves',
          attributes: {
            status: final_status,
            cancellation_reason: cancellation_reason,
          }.merge(cancellation_reason_comment.nil? ? {} : { cancellation_reason_comment: cancellation_reason_comment }),
        },
      }
    end

    before do
      patch "/api/v1/moves/#{move_id}", params: move_params, headers: headers, as: :json
      move.reload
    end

    shared_examples 'it sets the cancellation_reason' do
      it { expect(move.cancellation_reason).to eql cancellation_reason }
    end

    shared_examples 'it does not set the cancellation_reason' do
      it { expect(move.cancellation_reason).to be_nil }
    end

    shared_examples 'it sets the cancellation_reason_comment' do
      it { expect(move.cancellation_reason_comment).to eql cancellation_reason_comment }
    end

    context 'when a requested move is cancelled' do
      let(:initial_status) { 'requested' }
      let(:final_status) { 'cancelled' }
      let(:date) { Time.zone.today }
      let(:date_from) { nil }

      context 'when made_in_error' do
        let(:cancellation_reason) { 'made_in_error' }

        it_behaves_like 'an endpoint that responds with success 200'
        it_behaves_like 'it sets the cancellation_reason'
      end

      context 'when supplier_declined_to_move' do
        let(:cancellation_reason) { 'supplier_declined_to_move' }

        it_behaves_like 'an endpoint that responds with success 200'
        it_behaves_like 'it sets the cancellation_reason'
      end

      context 'when rejected' do
        let(:cancellation_reason) { 'rejected' }

        it_behaves_like 'an endpoint that responds with success 200'
        it_behaves_like 'it sets the cancellation_reason'
      end

      context 'when other' do
        let(:cancellation_reason) { 'other' }
        let(:cancellation_reason_comment) { 'some other reason' }

        it_behaves_like 'an endpoint that responds with success 200'
        it_behaves_like 'it sets the cancellation_reason'
        it_behaves_like 'it sets the cancellation_reason_comment'
      end

      context 'with an invalid reason' do
        let(:cancellation_reason) { 'fruit bats' }
        let(:errors_422) do
          [{ "title": 'Invalid cancellation_reason',
             "detail": /Cancellation reason is not included in the list/ }]
        end

        it_behaves_like 'it does not set the cancellation_reason'
        it_behaves_like 'an endpoint that responds with error 422'
      end

      context 'with a missing reason' do
        let(:cancellation_reason) { nil }
        let(:errors_422) do
          [{ "title": 'Invalid cancellation_reason',
             "detail": /Cancellation reason can't be blank/ }]
        end

        it_behaves_like 'it does not set the cancellation_reason'
        it_behaves_like 'an endpoint that responds with error 422'
      end
    end

    context 'when a proposed move is cancelled' do
      let(:initial_status) { 'proposed' }
      let(:final_status) { 'cancelled' }
      let(:date) { nil }
      let(:date_from) { Time.zone.today }

      context 'when made_in_error' do
        let(:cancellation_reason) { 'made_in_error' }

        it_behaves_like 'an endpoint that responds with success 200'
        it_behaves_like 'it sets the cancellation_reason'
      end

      context 'when supplier_declined_to_move' do
        let(:cancellation_reason) { 'supplier_declined_to_move' }

        it_behaves_like 'an endpoint that responds with success 200'
        it_behaves_like 'it sets the cancellation_reason'
      end

      context 'when rejected' do
        let(:cancellation_reason) { 'rejected' }

        it_behaves_like 'an endpoint that responds with success 200'
        it_behaves_like 'it sets the cancellation_reason'
      end

      context 'when other' do
        let(:cancellation_reason) { 'other' }
        let(:cancellation_reason_comment) { 'some other reason' }

        it_behaves_like 'an endpoint that responds with success 200'
        it_behaves_like 'it sets the cancellation_reason'
        it_behaves_like 'it sets the cancellation_reason_comment'
      end

      context 'with an invalid reason' do
        let(:cancellation_reason) { 'fruit bats' }
        let(:errors_422) do
          [{ "title": 'Invalid cancellation_reason',
             "detail": /Cancellation reason is not included in the list/ }]
        end

        it_behaves_like 'an endpoint that responds with error 422'
        it_behaves_like 'it does not set the cancellation_reason'
      end

      context 'with a missing reason' do
        let(:cancellation_reason) { nil }
        let(:errors_422) do
          [{ "title": 'Invalid cancellation_reason',
             "detail": /Cancellation reason can't be blank/ }]
        end

        it_behaves_like 'an endpoint that responds with error 422'
        it_behaves_like 'it does not set the cancellation_reason'
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
