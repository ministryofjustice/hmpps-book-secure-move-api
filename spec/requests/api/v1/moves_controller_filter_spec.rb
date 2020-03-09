# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController do
  let(:response_json) { JSON.parse(response.body) }
  let!(:application) { create(:application, owner_id: supplier.id) }
  let!(:access_token) { create(:access_token, application: application).token }
  let(:content_type) { ApiController::CONTENT_TYPE }

  describe 'GET /moves' do
    let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }

    context 'when filtering' do
      let!(:supplier) { create :supplier }
      let!(:location) { create :location, :with_moves, suppliers: [supplier] }
      let!(:filtered_out_moves) { create_list :move, 10 }

      before do
        get '/api/v1/moves', params: filter_params, headers: headers
      end

      describe 'by supplier_id' do
        let(:filter_params) { { filter: { supplier_id: supplier.id } } }

        it 'returns the right amount of moves' do
          expect(response_json['data'].size).to eq(10)
        end

        it 'returns the right moves' do
          expect(response_json['data'].map { |move| move['id'] }).to match_array(location.moves_from.pluck(:id))
        end
      end

      describe 'by from_location_id' do
        let(:filter_params) { { filter: { from_location_id: location.id } } }

        it 'only returns moves from the location' do
          expect(response_json['data'].map { |move| move['id'] }).to match_array(location.moves_from.pluck(:id))
        end
      end

      describe 'by created_at' do
        let(:first_date) { Date.new(2019, 12, 25) }
        let(:last_date) { Date.new(2019, 12, 27) }
        let(:middle_date) { Date.new(2019, 12, 26) }

        let(:target_move) { Move.find_by(created_at: first_date) }
        let(:target_move2) { Move.find_by(created_at:  middle_date) }
        let(:target_move3) { Move.find_by(created_at:  last_date) }
        let(:filter_params) {
          { filter: { created_at_from: first_date.to_s,
                                          created_at_to: last_date.to_s } }
        }
        let(:all_dates) { [first_date, middle_date, last_date] }

        before do
          create(:move, created_at: first_date)
          create(:move, created_at: middle_date)
          create(:move, created_at: last_date)
        end

        it 'returns the right amount of moves' do
          get '/api/v1/moves', headers: headers, params: filter_params

          expect(response_json['data'].map { |x| x['attributes']['created_at'] }).
            to match_array(all_dates.map(&:to_datetime).map(&:iso8601))
        end
      end
    end
  end
end
