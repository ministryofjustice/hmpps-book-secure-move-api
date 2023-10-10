# frozen_string_literal: true

require 'rails_helper'
require 'rack/test'

# 1.1 Police to Police police_transfer move for a person with a PNC identifier
# https://github.com/ministryofjustice/hmpps-book-secure-move-api/wiki/API-Walkthroughs

# rubocop:disable Rails/HttpPositionalArguments
RSpec.describe 'police-to-police transfer', type: :request, api_story: true do
  include Rack::Test::Methods
  include_context 'with mock prison-api'
  include_context 'with Nomis alerts reference data'

  let(:police_national_computer) { '05/886838E' }
  let(:person) { create(:person_without_profiles, police_national_computer:, prison_number: nil, criminal_records_office: nil) }
  let(:police1) { create(:location, :police) }
  let(:police2) { create(:location, :police) }
  let(:assessment_special_diet) { AssessmentQuestion.where(key: 'special_diet_or_allergy').first }

  # FRONTEND REQUESTS --------------------------
  let(:frontend_get_people_by_police_national_computer) do
    get "/api/people?filter[police_national_computer]=#{police_national_computer}"
    validate_response(last_response, schema: 'get_people_responses.yaml', strict: false, version: 'v2', status: 200)
  end

  let(:frontend_post_new_profile) do
    header 'Idempotency-Key', SecureRandom.uuid
    post "/api/people/#{frontend_person_id}/profiles", {
      data: {
        type: 'profiles',
        attributes: {
          assessment_answers: [{ title: assessment_special_diet.title, assessment_question_id: assessment_special_diet.id, comments: 'Extra Marmite' }],
        },
      },
    }.to_json
    validate_response(last_response, schema: 'post_profiles_responses.yaml', strict: false, version: 'v1', status: 201)
  end

  let(:frontend_post_police_to_police_move) do
    header 'Idempotency-Key', SecureRandom.uuid
    post '/api/moves/', {
      "data": {
        "type": 'moves',
        "attributes": {
          "date": '2020-07-21',
          "status": 'requested',
          "additional_information": 'example Police to Police transfer',
          "move_type": 'police_transfer',
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
              "id": police1.id,
            },
          },
          "to_location": {
            "data": {
              "type": 'locations',
              "id": police2.id,
            },
          },
        },
      },
    }.to_json
    validate_response(last_response, schema: 'post_moves_responses.yaml', strict: false, version: 'v2', status: 201)
  end

  let(:frontend_move_id) do
    frontend_post_police_to_police_move['data']['id']
  end

  let(:frontend_person_id) do
    frontend_get_people_by_police_national_computer['data'].first['id']
  end

  let(:frontend_profile_id) do
    frontend_post_new_profile['data']['id']
  end
  # FRONTEND REQUESTS --------------------------

  # SUPPLIER REQUESTS --------------------------
  let(:get_requested_moves) do
    get '/api/moves/?filter%5Bstatus%5D=requested&filter%5Bdate_from%5D=2020-07-21&filter%5Bdate_to%5D=2020-07-21'
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

    # create person and police stations
    person
    police1
    police2

    # Assign police1 location to Serco supplier
    create :supplier_location, location: police1, supplier: serco_supplier

    # These steps simulate the frontend creating a move request before the supplier processes it

    # get person record(s)
    frontend_get_people_by_police_national_computer

    # create a new profile with manually set alerts
    frontend_post_new_profile

    # create a new move from police station to police station
    frontend_post_police_to_police_move
  end

  it 'police to police transfer move' do
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
      expect(json.dig('data', 'id')).to eql frontend_move_id
      expect(json.dig('data', 'attributes', 'move_type')).to eql 'police_transfer'
      expect(json.dig('data', 'attributes', 'status')).to eql 'completed'
      expect(json.dig('data', 'attributes', 'date')).to eql '2020-07-21'
      expect(json.dig('data', 'relationships', 'profile', 'data', 'id')).to eql frontend_profile_id
      expect(json.dig('data', 'relationships', 'from_location', 'data', 'id')).to eql police1.id
      expect(json.dig('data', 'relationships', 'to_location', 'data', 'id')).to eql police2.id
    end
  end
end
# rubocop:enable Rails/HttpPositionalArguments
