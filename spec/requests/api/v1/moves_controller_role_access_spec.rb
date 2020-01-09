# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /moves' do
    let!(:application) { Doorkeeper::Application.create(name: 'test', owner: supplier) }

    let(:schema) { load_json_schema('get_moves_responses.json') }

    let(:supplier) { create :supplier }
    let(:pentonville) { create :location, suppliers: [supplier] }
    let(:birmingham) { create :location, key: 'hmp_birmingham', title: 'HMP Birmingham', nomis_agency_id: 'BMI' }
    let!(:pentonville_moves) { create_list :move, 10, from_location: pentonville }
    let!(:birmingham_moves) { create_list :move, 10, from_location: birmingham }

    before do
      next if RSpec.current_example.metadata[:skip_before]

      get '/api/v1/moves', headers: headers
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

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

  describe 'GET /moves/{moveId}' do
    let!(:application) { Doorkeeper::Application.create(name: 'test', owner: pentonville_supplier) }

    let(:schema) { load_json_schema('get_move_responses.json') }

    let(:pentonville_supplier) { create :supplier, name: 'pvi supplier' }
    let(:birmingham_supplier) { create :supplier, name: 'hmp supplier' }
    let(:pentonville) { create :location, suppliers: [pentonville_supplier] }
    let(:birmingham) { create :location, key: 'hmp_birmingham', title: 'HMP Birmingham', nomis_agency_id: 'BMI', suppliers: [birmingham_supplier] }
    let!(:pentonville_move) { create :move, from_location: pentonville }
    let!(:birmingham_move) { create :move, from_location: birmingham }

    let(:pentonville_resource_to_json) do
      JSON.parse(ActionController::Base.render(json: pentonville_move, include: MoveSerializer::INCLUDED_ATTRIBUTES))
    end

    context 'when successful' do
      before do
        get "/api/v1/moves/#{pentonville_move.id}", headers: headers
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to eq(pentonville_resource_to_json)
      end
    end

    context 'when supplier doesn\'t have rights to access the resource' do
      let(:detail_404) { "Couldn't find Move with 'id'=#{birmingham_move.id} [WHERE (from_location_id IN ('#{pentonville.id}'))]" }

      before do
        get "/api/v1/moves/#{birmingham_move.id}", headers: headers
      end

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end
end
