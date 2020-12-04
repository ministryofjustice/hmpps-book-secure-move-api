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
    let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{token.token}") }
    let(:schema) { load_yaml_schema('get_moves_responses.yaml') }
    let!(:moves) { create_list(:move, 2, supplier: pentonville_supplier) }
    let!(:other_moves) { create_list(:move, 2, supplier: birmingham_supplier) }

    before do
      next if RSpec.current_example.metadata[:skip_before]

      get '/api/v1/moves', headers: headers
    end

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

  context 'with swagger generation', :rswag, :with_client_authentication do
    let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }

    path '/moves/{move_id}' do
      let!(:pentonville_move) { create :move, from_location: pentonville }
      let!(:birmingham_move) { create :move, from_location: birmingham }

      get 'Returns the details of a move' do
        tags 'Moves'
        produces 'application/vnd.api+json'

        parameter name: :Authorization,
                  in: :header,
                  schema: {
                    type: 'string',
                    default: 'Bearer <your-client-token>',
                  },
                  required: true

        parameter name: 'Content-Type',
                  in: 'header',
                  description: 'Accepted request content type',
                  schema: {
                    type: 'string',
                    default: 'application/vnd.api+json',
                  },
                  required: true

        parameter name: :move_id,
                  in: :path,
                  description: 'The ID of the move',
                  schema: {
                    type: :string,
                  },
                  format: 'uuid',
                  example: '00525ecb-7316-492a-aae2-f69334b2a155',
                  required: true

        response '200', 'success' do
          let(:move_id) { pentonville_move.id }
          let(:resource_to_json) do
            JSON.parse(MoveSerializer.new(pentonville_move, include: MoveSerializer::SUPPORTED_RELATIONSHIPS).serializable_hash.to_json)
          end

          schema "$ref": 'get_move_responses.yaml#/200'

          run_test! do |_example|
            expect(response.headers['Content-Type']).to match(Regexp.escape(content_type))

            expect(JSON.parse(response.body)).to eq resource_to_json
          end
        end

        response '401', 'unauthorised' do
          let(:move_id) { birmingham_move.id }

          it_behaves_like 'a swagger 401 error'
        end
      end
    end
  end

  describe 'POST /moves' do
    let(:schema) { load_yaml_schema('post_moves_responses.yaml') }
    let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{token.token}") }

    let(:move_attributes) { attributes_for(:move) }
    let!(:person) { create(:person) }
    let(:resource_to_json) do
      JSON.parse(MoveSerializer.new(move, include: MoveSerializer::SUPPORTED_RELATIONSHIPS).serializable_hash.to_json)
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
  end

  describe 'PATCH /moves' do
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
      let(:detail_404) { "Couldn't find Move with 'id'=#{birmingham_move.id}" }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end
end
