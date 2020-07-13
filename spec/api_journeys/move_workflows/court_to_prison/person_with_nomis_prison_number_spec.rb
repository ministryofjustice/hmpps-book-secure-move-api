# frozen_string_literal: true

require 'rack/test'
# require 'rails_helper'

RSpec.describe 'dashboard outgoing moves' do
  include Rack::Test::Methods
  include_context 'Mock prison-api'

  # GIVEN a person with a prison number or police national computer number
  # WHEN the supplier wants to move the person from court to prison
  # THEN the supplier should call the api as outlined in the example below

  let(:app) { PecsMovePlatformBackend::Application } # Rack::Builder.parse_file("config.ru").first
  let(:prison_number) { 'G8133UA' }

  let(:get_people_by_prison_number) do
    get "/api/people?filter[prison_number]=#{prison_number}"
    validate_response('get_people_responses.yaml', version: 'v2')
    JSON.parse(last_response.body)
  end

  let(:first_person_id) {
    get_people_by_prison_number['data'].first['id']
  }

  let(:blank_profile) {
    {
      "data": {
        "type": "profiles"
      }
    }
  }

  let(:create_synchronised_profile) do
    post "/api/people/#{first_person_id}/profiles", blank_profile.to_json

    puts JSON.pretty_generate(JSON.parse(last_response.body))
    

    validate_response('post_profiles_responses.yaml', version: 'v1', status: 201)
    JSON.parse(last_response.body)
  end

  before do
    header 'Content-Type', 'application/vnd.api+json'
    header 'Accept', 'application/vnd.api+json; version=2'
    header 'Authorization', 'Bearer spoofed-token'
    create(:gender, :male)
    create(:ethnicity, :b2)
  end

  it 'court to prison move' do
    # get person record(s)
    get_people_by_prison_number

    # create a new profile synchronised with Nomis alerts
    create_synchronised_profile
  end





  def validate_response(schema_file, version: 'v1', strict: false, status: 200)
    schema = load_yaml_schema(schema_file, version: version)
    expect(JSON::Validator.fully_validate(schema, last_response.body, strict: strict, fragment: "#/#{status}")).to be_empty
    expect(last_response.status).to eql(status)
  end
end

# puts JSON.pretty_generate(x)