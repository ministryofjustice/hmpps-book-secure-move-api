# frozen_string_literal: true

require 'rack/test'

RSpec.describe 'dashboard outgoing moves' do
  include Rack::Test::Methods

  # GIVEN a person with a prison number or police national computer number
  # WHEN the supplier wants to move the person from court to prison
  # THEN the supplier should call the api as outlined in the example below

  let(:app) { Rack::Builder.parse_file("config.ru").first }

  let(:prison_number) { 'G8133UA' }

  it 'creates a move' do
    header 'CONTENT_TYPE', 'application/vnd.api+json'
    header 'Accept', 'application/vnd.api+json; version=2'
    header 'Authorization', 'Bearer spoofed-token'

    get "/api/people?filter[prison_number]=#{prison_number}"


    puts "\n\n----"
    puts last_response.body
    puts "----\n\n"
    # byebug
  end

end
