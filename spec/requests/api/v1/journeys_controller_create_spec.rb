# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::JourneysController do
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /moves/:move_id/journeys/:journey_id' do
    let(:supplier) { create(:supplier) }
    let(:application) { create(:application, owner: supplier) }
    let(:access_token) { create(:access_token, application: application).token }
    let(:headers) { { 'CONTENT_TYPE': content_type, 'Authorization': "Bearer #{access_token}" } }
    let(:content_type) { ApiController::CONTENT_TYPE }

    let(:locations) { create_list(:location, 2, suppliers: [supplier]) }
    let(:move) { create(:move, from_location: locations.first, to_location: locations.last) }


    # let(:journey) { create(:journey, move: move, supplier: supplier, client_timestamp: '2020-05-04T08:00:00Z', from_location: locations.first, to_location: locations.last) }

    let(:journey_params) {
      {
        data: {
          "type": 'journeys',
          "attributes": {
              "billable": false,
              "timestamp": '2020-05-04T09:00:00+01:00',
              "vehicle": {
                  "id": '12345678ABC',
                  "registration": 'AB12 CDE',
              },
          },
          "relationships": {
              "from_location": {
                  "data": {
                      "id": locations.first.id,
                      "type": 'locations',
                  },
              },
              "to_location": {
                  "data": {
                      "id": locations.last.id,
                      "type": 'locations',
                  },
              },
          },
        },
      }
    }

    before do
      post "/api/v1/moves/#{move.id}/journeys", params: journey_params, headers: headers, as: :json
    end

    context 'when successful' do
      let(:schema) { load_yaml_schema('post_journey_responses.yaml') }
      # let(:data) {
      #   {
      #       "id": journey.id,
      #       "type": 'journeys',
      #       "attributes": {
      #           "billable": false,
      #           "state": 'in_progress',
      #           "timestamp": '2020-05-04T09:00:00+01:00',
      #           "vehicle": {
      #             "id": '12345678ABC',
      #             "registration": 'AB12 CDE',
      #           },
      #       },
      #       "relationships": {
      #           "from_location": {
      #               "data": {
      #                   "id": locations.first.id,
      #                   "type": 'locations',
      #               },
      #           },
      #           "to_location": {
      #               "data": {
      #                   "id": locations.last.id,
      #                   "type": 'locations',
      #               },
      #           },
      #       },
      #   }
      # }

      it do
        puts JSON.pretty_generate(response_json)
      end

      # it_behaves_like 'an endpoint that responds with success 200'
      #
      # it 'returns the correct data' do
      #   expect(response_json).to include_json(data: data)
      # end
    end

    # context 'when unsuccessful' do
    #   let(:schema) { load_yaml_schema('error_responses.yaml') }
    #
    #   context 'when not authorized' do
    #     let(:access_token) { 'foo-bar' }
    #     let(:detail_401) { 'Token expired or invalid' }
    #
    #     it_behaves_like 'an endpoint that responds with error 401'
    #   end
    #
    #   context "when attempting to access another supplier's journey" do
    #     let(:journey) { create(:journey, move: move) } # another journey for a different supplier, same move
    #     let(:detail_404) { "Couldn't find Journey with 'id'=#{journey.id} [WHERE \"journeys\".\"move_id\" = $1 AND \"journeys\".\"supplier_id\" = $2]" }
    #
    #     it_behaves_like 'an endpoint that responds with error 404'
    #   end
    #
    #   context "when attempting to access another move's journey" do
    #     let(:journey) { create(:journey, supplier: supplier) } # another journey for a different move, same supplier
    #     let(:detail_404) { "Couldn't find Journey with 'id'=#{journey.id} [WHERE \"journeys\".\"move_id\" = $1 AND \"journeys\".\"supplier_id\" = $2]" }
    #
    #     it_behaves_like 'an endpoint that responds with error 404'
    #   end
    #
    #   context 'with an invalid CONTENT_TYPE header' do
    #     let(:content_type) { 'application/xml' }
    #
    #     it_behaves_like 'an endpoint that responds with error 415'
    #   end
    # end
  end
end
