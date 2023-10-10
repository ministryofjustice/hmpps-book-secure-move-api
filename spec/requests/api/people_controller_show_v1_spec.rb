# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PeopleController do
  let(:access_token) { 'spoofed-token' }
  let(:response_json) { JSON.parse(response.body) }
  let(:schema) { load_yaml_schema('get_person_responses.yaml', version: 'v1') }
  let(:person) { create(:person) }

  let(:headers) do
    {
      'CONTENT_TYPE': ApiController::CONTENT_TYPE,
      'Accept': 'application/vnd.api+json; version=1',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  describe 'GET /people/:id' do
    before do
      get "/api/people/#{person.id}", headers:
    end

    it_behaves_like 'an endpoint that responds with error 406'
  end
end
