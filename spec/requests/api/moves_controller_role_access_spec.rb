# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::MovesController do
  let!(:application) { Doorkeeper::Application.create(name: 'test', owner: pentonville_supplier) }
  let(:token) { create(:access_token, application: application) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  let(:pentonville_supplier) { create :supplier, name: 'pvi supplier' }
  let(:birmingham_supplier) { create :supplier, name: 'hmp supplier' }
  let!(:pentonville) { create :location, suppliers: [pentonville_supplier] }
  let!(:birmingham) do
    create :location,
           key: 'hmp_birmingham',
           title: 'HMP Birmingham',
           nomis_agency_id: 'BMI',
           suppliers: [birmingham_supplier]
  end

  describe 'GET /moves' do
    subject(:get_moves) { get '/api/v1/moves', headers: headers }

    let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{token.token}") }
    let(:schema) { load_yaml_schema('get_moves_responses.yaml') }
    let!(:moves) { create_list(:move, 2, supplier: pentonville_supplier) }
    let!(:other_moves) { create_list(:move, 2, supplier: birmingham_supplier) }

    before { get_moves }

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns only moves belonging to suppliers' do
        response_ids = response_json['data'].map { |move| move['id'] }.sort
        data_ids = moves.pluck(:id).sort
        expect(response_ids).to eq(data_ids)
      end

      it 'returns the right number of moves' do
        expect(response_json['data'].size).to be 2
      end
    end
  end

  describe 'GET /moves/{move_id}' do
    subject(:get_move) { get "/api/v1/moves/#{move_id}", headers: headers }

    let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{token.token}") }
    let(:schema) { load_yaml_schema('get_move_responses.yaml') }
    let!(:pentonville_move) { create :move, from_location: pentonville, supplier: pentonville_supplier }
    let!(:birmingham_move) { create :move, from_location: birmingham, supplier: birmingham_supplier }

    before { get_move }

    context 'when successful' do
      let(:move_id) { pentonville_move.id }

      it_behaves_like 'an endpoint that responds with success 200'
    end

    context 'when supplier doesn\'t have rights to view the resource' do
      let(:move_id) { birmingham_move.id }
      let(:detail_404) { "Couldn't find Move with 'id'=#{move_id}" }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end

  describe 'POST /moves' do
    subject(:post_moves) { post '/api/v1/moves', params: { data: data }, headers: headers, as: :json }

    let(:schema) { load_yaml_schema('post_moves_responses.yaml') }
    let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{token.token}") }

    let(:move_attributes) { attributes_for(:move) }
    let!(:person) { create(:person) }
    let(:resource_to_json) do
      JSON.parse(MoveSerializer.new(move, include: MoveSerializer::SUPPORTED_RELATIONSHIPS).serializable_hash.to_json)
    end

    context 'when successful' do
      before do
        image_data = File.read('spec/fixtures/Arctic_Tern.jpg')
        allow(NomisClient::Image).to receive(:get).and_return(image_data)
        allow(NomisClient::PersonalCareNeeds).to receive(:get).and_return([])
        allow(NomisClient::Alerts).to receive(:get).and_return([])
      end

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

      it_behaves_like 'an endpoint that responds with success 201' do
        before { post_moves }
      end

      it 'creates a move' do
        expect { post '/api/v1/moves', params: { data: data }, headers: headers, as: :json }
          .to change(Move, :count).by(1)
      end

      it 'returns the correct data' do
        post_moves
        expect(response_json).to eq resource_to_json
      end
    end
  end

  describe 'PATCH /moves/{move_id}' do
    subject(:patch_move) { patch "/api/v1/moves/#{move_id}", params: { data: move_params }, headers: headers, as: :json }

    let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{token.token}") }
    let(:schema) { load_yaml_schema('patch_move_responses.yaml') }

    let!(:pentonville_move) { create :move, from_location: pentonville, supplier: pentonville_supplier }
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

    before { patch_move }

    context 'when successful' do
      let(:move_id) { pentonville_move.id }

      it_behaves_like 'an endpoint that responds with success 200'

      it 'updates the status of a move' do
        expect(pentonville_move.reload.status).to eq 'cancelled'
      end

      it 'updates the additional_information of a move' do
        expect(pentonville_move.reload.additional_information).to eq 'some more info'
      end

      it 'updates the cancellation_reason of a move' do
        expect(pentonville_move.reload.cancellation_reason).to eq 'other'
      end

      it 'updates the cancellation_reason_comment of a move' do
        expect(pentonville_move.reload.cancellation_reason_comment).to eq 'some other reason'
      end
    end

    context 'when supplier doesn\'t have rights to write the resource' do
      let(:move_id) { birmingham_move.id }
      let(:detail_404) { "Couldn't find Move with 'id'=#{birmingham_move.id}" }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end
end
