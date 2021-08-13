# frozen_string_literal: true

require 'rails_helper'
require 'rack/test'

# 5.1 Court to Prison prison_remand move for a person with a PN identifier
# https://github.com/ministryofjustice/hmpps-book-secure-move-api/wiki/API-Walkthroughs

# rubocop:disable Rails/HttpPositionalArguments
RSpec.describe 'court to prison move', type: :request, api_story: true do
  include Rack::Test::Methods
  include_context 'with mock prison-api'
  include_context 'with Nomis alerts reference data'

  let(:prison_number) { 'G8133UA' }
  let(:prison) { create(:location, :prison) }
  let(:court) { create(:location, :court) }

  let(:get_people_by_prison_number) do
    get "/api/people?filter[prison_number]=#{prison_number}"
    validate_response(last_response, schema: 'get_people_responses.yaml', strict: false, version: 'v2', status: 200)
  end

  let(:post_synchronised_profile) do
    header 'Idempotency-Key', SecureRandom.uuid
    post "/api/people/#{person_id}/profiles", blank_profile_json
    validate_response(last_response, schema: 'post_profiles_responses.yaml', strict: false, version: 'v1', status: 201)
  end

  let(:post_court_to_prison_move) do
    header 'Idempotency-Key', SecureRandom.uuid
    post '/api/moves/', new_move_json
    validate_response(last_response, schema: 'post_moves_responses.yaml', strict: false, version: 'v2', status: 201)
  end

  let(:post_accept_move) do
    header 'Idempotency-Key', SecureRandom.uuid
    post "/api/moves/#{move_id}/accept", accept_move_json
    validate_response(last_response, status: 204)
  end

  let(:post_start_move) do
    header 'Idempotency-Key', SecureRandom.uuid
    post "/api/moves/#{move_id}/start", start_move_json
    validate_response(last_response, status: 204)
  end

  let(:post_complete_move) do
    header 'Idempotency-Key', SecureRandom.uuid
    post "/api/moves/#{move_id}/complete", complete_move_json
    validate_response(last_response, status: 204)
  end

  let(:get_move) do
    get "/api/moves/#{move_id}?include=profile"
    validate_response(last_response, schema: 'get_move_responses.yaml', strict: false, version: 'v2', status: 200)
  end

  let(:person_id) do
    get_people_by_prison_number['data'].first['id']
  end

  let(:profile_id) do
    post_synchronised_profile['data']['id']
  end

  let(:move_id) do
    post_court_to_prison_move['data']['id']
  end

  let(:blank_profile_json) do
    { "data": { "type": 'profiles' } }.to_json
  end

  let(:new_move_json) do
    {
      "data": {
        "type": 'moves',
        "attributes": {
          "date": '2020-07-06',
          "time_due": '2020-07-06T14:19:22+01:00',
          "status": 'requested',
          "additional_information": 'example court to prison transfer',
          "move_type": 'prison_remand',
        },
        "relationships": {
          "profile": {
            "data": {
              "type": 'profiles',
              "id": profile_id,
            },
          },
          "from_location": {
            "data": {
              "type": 'locations',
              "id": court.id,
            },
          },
          "to_location": {
            "data": {
              "type": 'locations',
              "id": prison.id,
            },
          },
        },
      },
    }.to_json
  end

  let(:accept_move_json) do
    {
      "data": {
        "type": 'accepts',
        "attributes": {
          "timestamp": '2020-07-07T10:10:10.123Z',
        },
      },
    }.to_json
  end

  let(:start_move_json) do
    {
      "data": {
        "type": 'starts',
        "attributes": {
          "timestamp": '2020-07-07T11:11:11.123Z',
        },
      },
    }.to_json
  end

  let(:complete_move_json) do
    {
      "data": {
        "type": 'completes',
        "attributes": {
          "timestamp": '2020-07-07T12:12:12.123Z',
        },
      },
    }.to_json
  end

  before do
    header 'Content-Type', 'application/vnd.api+json'
    header 'Accept', 'application/vnd.api+json; version=2'
    header 'Authorization', 'Bearer spoofed-token'

    # Assign location court to Serco supplier
    create :supplier_location, location: court, supplier: serco_supplier
    create :category, :cat_c
  end

  it 'court to prison move' do
    # get person record(s)
    get_people_by_prison_number

    # create a new profile synchronised with Nomis alerts
    post_synchronised_profile

    # create a new move from court to prison
    post_court_to_prison_move

    # accept the move, changing status from request to booked
    post_accept_move

    # start the move, changing status from booked to in_transit
    post_start_move

    # complete the move, changing its status from in_transit to completed
    post_complete_move

    # finally, retrieve the move and verify it is completed
    get_move.tap do |json|
      expect(json.dig('data', 'attributes', 'move_type')).to eql 'prison_remand'
      expect(json.dig('data', 'attributes', 'status')).to eql 'completed'
      expect(json.dig('data', 'attributes', 'date')).to eql '2020-07-06'
      expect(json.dig('data', 'relationships', 'profile', 'data', 'id')).to eql profile_id
      expect(json.dig('data', 'relationships', 'from_location', 'data', 'id')).to eql court.id
      expect(json.dig('data', 'relationships', 'to_location', 'data', 'id')).to eql prison.id
    end
  end
end
# rubocop:enable Rails/HttpPositionalArguments
