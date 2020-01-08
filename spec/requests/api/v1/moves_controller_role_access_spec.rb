# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController, with_client_authentication: true do
  let!(:application) { Doorkeeper::Application.create(name: 'test', owner: supplier) }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /moves' do
    let(:schema) { load_json_schema('get_moves_responses.json') }

    let(:supplier) { create :supplier }
    let(:pentonville) { create :location, suppliers: [supplier] }
    let(:birmingham) { create :location, key: 'hmp_birmingham', title: 'HMP Birmingham', nomis_agency_id: 'BMI' }
    let!(:pentonville_moves) { create_list :move, 10, from_location: pentonville }
    let!(:birmingham_moves) { create_list :move, 10, from_location: birmingham }

    before do
      get '/api/v1/moves', headers: headers
    end

    it 'returns only moves belonging to suppliers' do
      response_ids = response_json['data'].map { |move| move['id'] }.sort
      data_ids = pentonville_moves.pluck(:id).sort
      expect(response_ids).to eq(data_ids)
    end

    it 'returns the right number of moves' do
      expect(response_json['data'].size).to be 10
    end
  end
end
