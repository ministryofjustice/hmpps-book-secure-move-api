# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }
  let(:pentonville_supplier) { create :supplier, name: 'pvi supplier' }
  let(:birmingham_supplier) { create :supplier, name: 'hmp supplier' }
  let(:pentonville) { create :location, suppliers: [pentonville_supplier] }
  let(:birmingham) do
    create :location,
           key: 'hmp_birmingham', title: 'HMP Birmingham', nomis_agency_id: 'BMI', suppliers: [birmingham_supplier]
  end

  describe 'GET /moves' do
    let!(:application) { Doorkeeper::Application.create(name: 'test', owner: pentonville_supplier) }

    let(:schema) { load_json_schema('get_moves_responses.json') }

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
      let(:detail_404) do
        "Couldn't find Move with 'id'=#{birmingham_move.id} [WHERE (from_location_id IN ('#{pentonville.id}'))]"
      end

      before do
        get "/api/v1/moves/#{birmingham_move.id}", headers: headers
      end

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end

  describe 'POST /moves' do
    let!(:application) { Doorkeeper::Application.create(name: 'test', owner: pentonville_supplier) }
    let(:schema) { load_json_schema('post_moves_responses.json') }

    let(:move_attributes) { attributes_for(:move) }
    let!(:person) { create(:person) }
    let(:data) do
      {
        type: 'moves',
        attributes: move_attributes,
        relationships: {
          person: { data: { type: 'people', id: person.id } },
          from_location: { data: { type: 'locations', id: from_location.id } },
          to_location: to_location ? { data: { type: 'locations', id: to_location.id } } : nil
        }
      }
    end
    let(:resource_to_json) do
      JSON.parse(ActionController::Base.render(json: move, include: MoveSerializer::INCLUDED_ATTRIBUTES))
    end

    before do
      next if RSpec.current_example.metadata[:skip_before]

      post '/api/v1/moves', params: { data: data }, headers: headers, as: :json
    end

    context 'when successful' do
      let(:move) { Move.first }

      let!(:person) { create(:person) }
      let(:data) do
        {
          type: 'moves',
          attributes: move_attributes,
          relationships: {
            person: { data: { type: 'people', id: person.id } },
            from_location: { data: { type: 'locations', id: pentonville.id } },
            to_location: { data: { type: 'locations', id: birmingham.id } }
          }
        }
      end

      it_behaves_like 'an endpoint that responds with success 201'

      it 'creates a move', skip_before: true do
        expect { post '/api/v1/moves', params: { data: data }, headers: headers, as: :json }
          .to change(Move, :count).by(1)
      end

      it 'returns the correct data' do
        expect(response_json).to eq resource_to_json
      end
    end

    context 'when supplier doesn\'t have rights to write the resource' do
      let(:schema) { load_json_schema('post_moves_responses.json') }

      let(:move) { Move.first }
      let!(:person) { create(:person) }
      let(:data) do
        {
          type: 'moves',
          attributes: move_attributes,
          relationships: {
            person: { data: { type: 'people', id: person.id } },
            from_location: { data: { type: 'locations', id: birmingham.id } },
            to_location: { data: { type: 'locations', id: pentonville.id } }
          }
        }
      end
      let(:detail_401) { 'You are not authorized to access this page.' }

      it_behaves_like 'an endpoint that responds with error 401'
    end
  end
end
