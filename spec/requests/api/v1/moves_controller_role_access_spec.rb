# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController, with_client_authentication: true do
  let!(:application) { Doorkeeper::Application.create(name: 'test', owner: pentonville_supplier) }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  let(:pentonville_supplier) { create :supplier, name: 'pvi supplier' }
  let(:birmingham_supplier) { create :supplier, name: 'hmp supplier' }
  let!(:pentonville) { create :location, suppliers: [pentonville_supplier] }
  let!(:birmingham) do
    create :location,
           key: 'hmp_birmingham', title: 'HMP Birmingham', nomis_agency_id: 'BMI', suppliers: [birmingham_supplier]
  end

  describe 'GET /moves' do
    let(:schema) { load_json_schema('get_moves_responses.json') }

    let!(:pentonville) { create :location, :with_moves, suppliers: [pentonville_supplier] }
    let!(:birmingham) do
      create :location, :with_moves,
             key: 'hmp_birmingham', title: 'HMP Birmingham', nomis_agency_id: 'BMI', suppliers: [birmingham_supplier]
    end

    before do
      next if RSpec.current_example.metadata[:skip_before]

      get '/api/v1/moves', headers: headers
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns only moves belonging to suppliers' do
        response_ids = response_json['data'].map { |move| move['id'] }.sort
        data_ids = pentonville.moves_from.pluck(:id).sort
        expect(response_ids).to eq(data_ids)
      end

      it 'returns the right number of moves' do
        expect(response_json['data'].size).to be 10
      end
    end
  end

  describe 'GET /moves/{move_id}' do
    let(:schema) { load_json_schema('get_move_responses.json') }
    let!(:pentonville_move) { create :move, from_location: pentonville }
    let!(:birmingham_move) { create :move, from_location: birmingham }

    before do
      get "/api/v1/moves/#{move_id}", headers: headers
    end

    context 'when the correct supplier' do
      let(:move_id) { pentonville_move.id }
      let(:resource_to_json) do
        JSON.parse(ActionController::Base.render(json: pentonville_move, include: MoveSerializer::INCLUDED_ATTRIBUTES))
      end

      it 'Returns the details of a move' do
        expect(JSON.parse(response.body)).to eq resource_to_json
      end
    end

    context 'when the wrong supplier' do
      let(:move_id) { birmingham_move.id }
      let(:detail_404) { "Couldn't find Move with 'id'=#{move_id} [WHERE (from_location_id IN ('#{pentonville.id}'))]" }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end

  describe 'POST /moves' do
    let(:schema) { load_json_schema('post_moves_responses.json') }

    let(:move_attributes) { attributes_for(:move) }
    let!(:person) { create(:person) }
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
            to_location: { data: { type: 'locations', id: birmingham.id } },
          },
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
            to_location: { data: { type: 'locations', id: pentonville.id } },
          },
        }
      end
      let(:detail_401) { 'You are not authorized to access this page.' }

      it_behaves_like 'an endpoint that responds with error 401'
    end
  end

  describe 'PATCH /moves' do
    let(:schema) { load_json_schema('patch_move_responses.json') }

    let!(:pentonville_move) { create :move, from_location: pentonville }
    let!(:birmingham_move) { create :move, from_location: birmingham }

    let(:move_params) do
      {
        type: 'moves',
        attributes: {
          status: 'cancelled',
          additional_information: 'some more info',
          cancellation_reason: 'other',
          cancellation_reason_comment: 'some other reason',
        },
      }
    end

    before do
      patch "/api/v1/moves/#{move_id}", params: { data: move_params }, headers: headers, as: :json
    end

    context 'when successful' do
      let(:move_id) { pentonville_move.id }

      it_behaves_like 'an endpoint that responds with success 200'

      it 'updates the status of a move', skip_before: true do
        patch "/api/v1/moves/#{move_id}", params: { data: move_params }, headers: headers, as: :json
        expect(pentonville_move.reload.status).to eq 'cancelled'
      end

      it 'updates the additional_information of a move', skip_before: true do
        patch "/api/v1/moves/#{move_id}", params: { data: move_params }, headers: headers, as: :json
        expect(pentonville_move.reload.additional_information).to eq 'some more info'
      end

      it 'updates the cancellation_reason of a move', skip_before: true do
        patch "/api/v1/moves/#{move_id}", params: { data: move_params }, headers: headers, as: :json
        expect(pentonville_move.reload.cancellation_reason).to eq 'other'
      end

      it 'updates the cancellation_reason_comment of a move', skip_before: true do
        patch "/api/v1/moves/#{move_id}", params: { data: move_params }, headers: headers, as: :json
        expect(pentonville_move.reload.cancellation_reason_comment).to eq 'some other reason'
      end
    end

    context 'when supplier doesn\'t have rights to write the resource' do
      let(:move_id) { birmingham_move.id }

      let(:detail_404) { "Couldn't find Move with 'id'=#{birmingham_move.id} [WHERE (from_location_id IN ('#{pentonville.id}'))]" }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end

  describe 'DELETE /moves/{move_id}' do
    let(:schema) { load_json_schema('delete_move_responses.json') }

    let!(:pentonville_move) { create :move, from_location: pentonville }
    let!(:birmingham_move) { create :move, from_location: birmingham }

    before do
      next if RSpec.current_example.metadata[:skip_before]

      delete "/api/v1/moves/#{move_id}", headers: headers
    end

    context 'when successful' do
      let(:resource_to_json) do
        JSON.parse(ActionController::Base.render(json: pentonville_move, include: MoveSerializer::INCLUDED_ATTRIBUTES))
      end
      let(:move_id) { pentonville_move.id }

      it_behaves_like 'an endpoint that responds with success 200'

      it 'deletes the move', skip_before: true do
        expect { delete "/api/v1/moves/#{move_id}", headers: headers }
          .to change(Move, :count).by(-1)
      end

      it 'returns the correct data' do
        expect(response_json).to eq resource_to_json
      end
    end

    context 'when supplier doesn\'t have rights to write the resource' do
      let(:move_id) { birmingham_move.id }

      let(:detail_404) { "Couldn't find Move with 'id'=#{birmingham_move.id} [WHERE (from_location_id IN ('#{pentonville.id}'))]" }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end
end
