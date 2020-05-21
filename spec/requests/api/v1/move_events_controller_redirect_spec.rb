# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MoveEventsController do
  let(:response_json) { JSON.parse(response.body) }

  describe 'POST /moves/:move_id/redirect' do
    let(:schema) { load_yaml_schema('post_move_redirect_responses.yaml') }

    let(:supplier) { create(:supplier) }
    let(:application) { create(:application, owner_id: supplier.id) }
    let(:access_token) { create(:access_token, application: application).token }
    let(:headers) { { 'CONTENT_TYPE': content_type, 'Authorization': "Bearer #{access_token}" } }
    let(:content_type) { ApiController::CONTENT_TYPE }

    let(:move) { create(:move) }
    let(:move_id) { move.id }
    let(:new_location) { create(:location) }
    let(:redirect_params) do
      {
        data: {
          type: 'redirect',
          attributes: {
            timestamp: '2020-04-23T18:25:43.511Z',
            notes: 'requested by PMU',
          },
          relationships: {
            to_location: { data: { type: 'locations', id: new_location.id } },
          },
        },
      }
    end

    before do
      allow(Notifier).to receive(:prepare_notifications)
      post "/api/v1/moves/#{move_id}/redirect", params: redirect_params, headers: headers, as: :json
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

    context 'with a bad request' do
      let(:redirect_params) { nil }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'when not authorized' do
      let(:access_token) { 'foo-bar' }
      let(:detail_401) { 'Token expired or invalid' }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with a missing move_id' do
      let(:move_id) { 'foo-bar' }
      let(:detail_404) { "Couldn't find Move with 'id'=foo-bar" }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with a reference to a missing relationship' do
      let(:new_location) { build(:location) }
      let(:detail_404) { "Couldn't find Location without an ID" }

      it_behaves_like 'an endpoint that responds with error 404'
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
