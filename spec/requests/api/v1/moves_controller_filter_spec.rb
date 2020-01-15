# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /moves' do
    context 'when filtering' do
      let!(:supplier) { create :supplier }
      let!(:location) { create :location, :with_moves, suppliers: [supplier] }
      let!(:filtered_out_moves) { create_list :move, 10 }
      let(:filter_params) { { filter: { supplier_id: supplier.id } } }

      before do
        get '/api/v1/moves', headers: headers, params: filter_params
      end

      describe 'by supplier_id' do
        it 'returns the right amount of moves' do
          expect(response_json['data'].size).to eq(10)
        end

        it 'returns the right moves' do
          expect(response_json['data'].map { |move| move['id'] }.sort).to eq(location.moves_from.pluck(:id).sort)
        end
      end
    end
  end
end
