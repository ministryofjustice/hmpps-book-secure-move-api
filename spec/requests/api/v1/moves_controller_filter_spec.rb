# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /moves' do
    context 'when filtering' do
      let(:move_ids) { response_json['data'].map { |move| move['id'] } }

      describe 'by active' do
        let(:filter_params) { { filter: { active: true } } }
        let!(:move) { create(:move) }

        before do
          create(:move, :cancelled)
          create(:move, :proposed)
        end

        it 'filters out inactive moves' do
          get '/api/v1/moves', headers: headers, params: filter_params

          expect(move_ids).to eq([move.id])
        end
      end

      describe 'by supplier_id' do
        let!(:supplier) { create :supplier }
        let!(:location) { create :location, :with_moves, suppliers: [supplier] }
        let!(:filtered_out_moves) { create_list :move, 10 }
        let(:filter_params) { { filter: { supplier_id: supplier.id } } }

        before do
          get '/api/v1/moves', headers: headers, params: filter_params
        end

        it 'returns the right amount of moves' do
          expect(response_json['data'].size).to eq(10)
        end

        it 'returns the right moves' do
          expect(response_json['data'].map { |move| move['id'] }.sort).to eq(location.moves_from.pluck(:id).sort)
        end
      end

      describe 'by created_at' do
        let(:first_date) { Date.new(2019, 12, 25) }
        let(:last_date) { Date.new(2019, 12, 27) }
        let(:middle_date) { Date.new(2019, 12, 26) }

        let(:target_move) { Move.find_by(created_at: first_date) }
        let(:target_move2) { Move.find_by(created_at:  middle_date) }
        let(:target_move3) { Move.find_by(created_at:  last_date) }
        let(:filter_params) { { filter: { created_at_from: first_date.to_s, created_at_to: last_date.to_s } } }
        let(:all_dates) { [first_date, middle_date, last_date] }

        before do
          create(:move, created_at: first_date)
          create(:move, created_at: middle_date)
          create(:move, created_at: last_date)
        end

        it 'returns the right amount of moves' do
          get '/api/v1/moves', headers: headers, params: filter_params

          expect(response_json['data'].map { |x| x['attributes']['created_at'] }).
            to match_array all_dates.map(&:to_datetime).map(&:iso8601)
        end
      end
    end
  end
end
