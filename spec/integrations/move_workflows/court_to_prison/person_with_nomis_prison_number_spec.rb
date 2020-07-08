# frozen_string_literal: true

require 'rack/test'

RSpec.describe 'dashboard outgoing moves' do
  include Rack::Test::Methods

  # GIVEN a person with a prison number or police national computer number
  # WHEN the supplier wants to move the person from court to prison
  # THEN the supplier should call the api as outlined in the example below

  let(:app) { Rack::Builder.parse_file("config.ru").first }
  let(:headers) do
    {
        'CONTENT_TYPE': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json; version=2',
        'Authorization': "Bearer spoofed-token",
    }
  end

  let(:prison_number) { 'F008AR' }
  let(:get_people_index) { get "/api/people?filter[prison_number]=#{prison_number}", headers: headers }

  it 'creates a move' do
    get_people_index
    puts last_response.body
    byebug
  end

end
