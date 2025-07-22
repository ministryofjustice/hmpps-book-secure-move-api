# frozen_string_literal: true

require 'rails_helper'
require 'rack/test'

# 6.1 IPT Prison to Prison prison_transfer move for a person with a PN identifier
# https://github.com/ministryofjustice/hmpps-book-secure-move-api/wiki/API-Walkthroughs

RSpec.describe 'singleton', :api_story, type: :request do
  include Rack::Test::Methods
  include_context 'with mock prison-api'
  include_context 'with mock prisoner-search-api'
  include_context 'with Nomis alerts reference data'

  let(:prison_number) { 'G8133UA' }
  let(:prison1) { create(:location, :prison) }
  let(:prison2) { create(:location, :prison) }
  let(:prison_transfer_reason) { create(:prison_transfer_reason) }

  # FRONTEND REQUESTS --------------------------
  let(:frontend_get_people_by_prison_number) do
    get "/api/people?filter[prison_number]=#{prison_number}"
    validate_response(last_response, schema: 'get_people_responses.yaml', strict: false, version: 'v2', status: 200)
  end

  let(:frontend_post_synchronised_profile) do
    header 'Idempotency-Key', SecureRandom.uuid
    post "/api/people/#{frontend_person_id}/profiles", {
      "data": {
        "type": 'profiles',
      },
    }.to_json
    validate_response(last_response, schema: 'post_profiles_responses.yaml', strict: false, version: 'v1', status: 201)
  end

  let(:frontend_post_prison_to_prison_move) do
    header 'Idempotency-Key', SecureRandom.uuid
    post '/api/moves/', {
      "data": {
        "type": 'moves',
        "attributes": {
          "date_from": '2020-07-21',
          "date_to": '2020-07-23',
          "move_agreed": true,
          "move_agreed_by": 'Fred Bloggs',
          "status": 'proposed',
          "additional_information": 'example IPT singleton prison to prison transfer',
          "move_type": 'prison_transfer',
        },
        "relationships": {
          "profile": {
            "data": {
              "type": 'profiles',
              "id": frontend_profile_id,
            },
          },
          "from_location": {
            "data": {
              "type": 'locations',
              "id": prison1.id,
            },
          },
          "to_location": {
            "data": {
              "type": 'locations',
              "id": prison2.id,
            },
          },
          "prison_transfer_reason": {
            "data": {
              "type": 'prison_transfer_reasons',
              "id": prison_transfer_reason.id,
            },
          },
        },
      },
    }.to_json
    validate_response(last_response, schema: 'post_moves_responses.yaml', strict: false, version: 'v2', status: 201)
  end

  let(:frontend_post_approve_move) do
    header 'Idempotency-Key', SecureRandom.uuid
    post "/api/moves/#{frontend_created_move_id}/approve", {
      "data": {
        "type": 'approve',
        "attributes": {
          "timestamp": '2020-07-21T09:09:09.123Z',
          "date": '2020-07-22',
        },
      },
    }.to_json
    validate_response(last_response, status: 204)
  end

  let(:frontend_created_move_id) do
    frontend_post_prison_to_prison_move['data']['id']
  end

  let(:frontend_person_id) do
    frontend_get_people_by_prison_number['data'].first['id']
  end

  let(:frontend_profile_id) do
    frontend_post_synchronised_profile['data']['id']
  end
  # FRONTEND REQUESTS --------------------------

  # SUPPLIER REQUESTS --------------------------
  let(:get_requested_moves) do
    get '/api/moves/?filter%5Bstatus%5D=requested&filter%5Bdate_from%5D=2020-07-21&filter%5Bdate_to%5D=2020-07-23'
    validate_response(last_response, schema: 'get_moves_responses.yaml', strict: false, version: 'v2', status: 200)
  end

  let(:post_accept_move) do
    header 'Idempotency-Key', SecureRandom.uuid
    post "/api/moves/#{move_id}/accept", {
      "data": {
        "type": 'accepts',
        "attributes": {
          "timestamp": '2020-07-22T10:10:10.123Z',
        },
      },
    }.to_json
    validate_response(last_response, status: 204)
  end

  let(:post_start_move) do
    header 'Idempotency-Key', SecureRandom.uuid
    post "/api/moves/#{move_id}/start", {
      "data": {
        "type": 'starts',
        "attributes": {
          "timestamp": '2020-07-22T11:11:11.123Z',
        },
      },
    }.to_json
    validate_response(last_response, status: 204)
  end

  let(:post_complete_move) do
    header 'Idempotency-Key', SecureRandom.uuid
    post "/api/moves/#{move_id}/complete", {
      "data": {
        "type": 'completes',
        "attributes": {
          "timestamp": '2020-07-22T12:12:12.123Z',
        },
      },
    }.to_json
    validate_response(last_response, status: 204)
  end

  let(:get_move) do
    get "/api/moves/#{move_id}?include=profile"
    validate_response(last_response, schema: 'get_move_responses.yaml', strict: false, version: 'v2', status: 200)
  end
  # SUPPLIER REQUESTS --------------------------

  let(:move_id) do
    get_requested_moves['data'].first['id']
  end

  before do
    header 'Content-Type', 'application/vnd.api+json'
    header 'Accept', 'application/vnd.api+json; version=2'
    header 'Authorization', 'Bearer spoofed-token'

    # Assign prison1 location to Serco supplier
    create :supplier_location, location: prison1, supplier: serco_supplier

    # These steps simulate the frontend creating a move request

    # get person record(s)
    frontend_get_people_by_prison_number

    # create a new profile synchronised with Nomis alerts
    frontend_post_synchronised_profile

    # create a new move from prison to prison
    frontend_post_prison_to_prison_move

    # approve the move, changing status from proposed to requested
    frontend_post_approve_move
  end

  it 'singleton prison to prison move' do
    # get requested moves awaiting processing
    get_requested_moves

    # accept the move, changing status from request to booked
    post_accept_move

    # start the move, changing status from booked to in_transit
    post_start_move

    # complete the move, changing its status from in_transit to completed
    post_complete_move

    # finally, retrieve the move and verify it is completed
    get_move.tap do |json|
      expect(json.dig('data', 'id')).to eql frontend_created_move_id
      expect(json.dig('data', 'attributes', 'move_type')).to eql 'prison_transfer'
      expect(json.dig('data', 'attributes', 'status')).to eql 'completed'
      expect(json.dig('data', 'attributes', 'date')).to eql '2020-07-22'
      expect(json.dig('data', 'relationships', 'profile', 'data', 'id')).to eql frontend_profile_id
      expect(json.dig('data', 'relationships', 'from_location', 'data', 'id')).to eql prison1.id
      expect(json.dig('data', 'relationships', 'to_location', 'data', 'id')).to eql prison2.id
    end
  end
end
