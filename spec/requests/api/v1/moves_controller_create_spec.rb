# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  let(:resource_to_json) do
    JSON.parse(ActionController::Base.render(json: move, include: MoveSerializer::INCLUDED_ATTRIBUTES))
  end

  let(:detail_404) { "Couldn't find Move with 'id'=UUID-not-found" }

  describe 'POST /moves' do
    let(:schema) { load_json_schema('post_moves_responses.json') }

    let(:move_attributes) { attributes_for(:move) }
    let!(:from_location) { create :location }
    let!(:to_location) { create :location, :court }
    let!(:person) { create(:person) }
    let(:data) do
      {
        type: 'moves',
        attributes: move_attributes,
        relationships: {
          person: { data: { type: 'people', id: person.id } },
          from_location: { data: { type: 'locations', id: from_location.id } },
          to_location: to_location ? { data: { type: 'locations', id: to_location.id } } : nil,
        },
      }
    end

    before do
      next if RSpec.current_example.metadata[:skip_before]

      post '/api/v1/moves', params: { data: data }, headers: headers, as: :json
    end

    context 'when successful' do
      let(:move) { Move.first }

      it_behaves_like 'an endpoint that responds with success 201'

      it 'creates a move', skip_before: true do
        expect { post '/api/v1/moves', params: { data: data }, headers: headers, as: :json }
          .to change(Move, :count).by(1)
      end

      it 'returns the correct data' do
        expect(response_json).to eq resource_to_json
      end

      it 'sets the additional_information' do
        expect(response_json.dig('data', 'attributes', 'additional_information')).to match 'some more info'
      end

      context 'without a `to_location`' do
        let(:to_location) { nil }
        let(:data) do
          {
            type: 'moves',
            attributes: move_attributes.merge(move_type: nil),
            relationships: {
              person: { data: { type: 'people', id: person.id } },
              from_location: { data: { type: 'locations', id: from_location.id } },
            },
          }
        end

        it_behaves_like 'an endpoint that responds with success 201'

        it 'creates a move', skip_before: true do
          expect { post '/api/v1/moves', params: { data: data }, headers: headers, as: :json }
            .to change(Move, :count).by(1)
        end

        it 'sets the move_type to `prison_recall`' do
          expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'prison_recall'
        end
      end

      context 'with explicit `move_type`' do
        let(:move_attributes) { attributes_for(:move, move_type: 'prison_recall') }

        it_behaves_like 'an endpoint that responds with success 201'

        it 'creates a move', skip_before: true do
          expect { post '/api/v1/moves', params: { data: data }, headers: headers, as: :json }
            .to change(Move, :count).by(1)
        end

        it 'sets the move_type to `prison_recall`' do
          expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'prison_recall'
        end
      end
    end

    context 'with a bad request' do
      let(:data) { nil }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      let(:detail_401) { 'Token expired or invalid' }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with a reference to a missing relationship' do
      let(:person) { Person.new }
      let(:detail_404) { "Couldn't find Person without an ID" }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end

    context 'with validation errors' do
      let(:move_attributes) { attributes_for(:move).except(:date).merge(status: 'invalid') }

      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable entity',
            'detail' => "Date can't be blank",
            'source' => { 'pointer' => '/data/attributes/date' },
            'code' => 'blank',
          },
          {
            'title' => 'Unprocessable entity',
            'detail' => 'Status is not included in the list',
            'source' => { 'pointer' => '/data/attributes/status' },
            'code' => 'inclusion',
          },
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422'
    end
  end
end
