# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController do
  let(:response_json) { JSON.parse(response.body) }
  let(:supplier) { create :supplier }
  let(:alternative_supplier) { create :supplier }
  let(:application) { create(:application, owner_id: supplier.id) }
  let(:access_token) { create(:access_token, application: application).token }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
  let(:schema) { load_yaml_schema('get_moves_responses.yaml') }
  let(:expected_moves) { nil }
  let(:unexpected_moves) { nil }

  shared_examples 'it returns the correct moves' do
    let(:size) { response_json['data'].size }
    let(:ids) { response_json['data'].map { |move| move['id'] } }

    it 'contains all the expected moves' do
      expect(ids).to match_array(expected_moves.pluck(:id))
    end
    it 'does not contain any unexpected moves' do
      # NB: this is a necessary test to catch a dodgy test which has unexpected moves in the expected moves
      expect(ids & unexpected_moves.pluck(:id)).to be_empty
    end
  end

  describe 'GET /moves' do
    before do
      expected_moves # forces creation of expected and unexpected moves prior to querying data
      unexpected_moves
      get '/api/v1/moves', params: filter_params, headers: headers
    end

    describe 'by supplier_id' do
      let(:filter_params) { { filter: { supplier_id: supplier.id } } }
      let(:supplier_location) { create :location, :with_moves, suppliers: [supplier] }
      let(:alternative_supplier_location) { create :location, :with_moves, suppliers: [alternative_supplier] }
      let(:expected_moves) { Move.where(from_location: supplier_location) }
      let(:unexpected_moves) { Move.where(from_location: alternative_supplier_location) }

      it_behaves_like 'it returns the correct moves'
    end

    describe 'by from_location_id' do
      let(:filter_params) { { filter: { from_location_id: location.id } } }
      let(:location) { create :location }
      let(:expected_moves) { create_list :move, 3, from_location: location }
      let(:unexpected_moves) { create_list :move, 3 }

      it_behaves_like 'it returns the correct moves'
    end

    describe 'by created_at' do
      let(:first_date) { DateTime.new(2019, 12, 25, 12) }
      let(:middle_date) { DateTime.new(2019, 12, 26, 12) }
      let(:last_date) { DateTime.new(2019, 12, 27) }

      let(:first_moves) { create_list :move, 2, created_at: first_date }
      let(:middle_moves) { create_list :move, 2, created_at: middle_date }
      let(:last_moves) { create_list :move, 2, created_at: last_date }

      context 'with a created_at_from' do
        let(:filter_params) { { filter: { created_at_from: middle_date.to_date.to_s } } }
        let(:expected_moves) { middle_moves + last_moves }
        let(:unexpected_moves) { first_moves }

        it_behaves_like 'it returns the correct moves'
      end

      context 'with a created_at_to' do
        let(:filter_params) { { filter: { created_at_to: middle_date.to_date.to_s } } }
        let(:expected_moves) { first_moves + middle_moves }
        let(:unexpected_moves) { last_moves }

        it_behaves_like 'it returns the correct moves'
      end

      context 'with a created_at range' do
        let(:filter_params) { { filter: { created_at_from: first_date.to_date.to_s, created_at_to: middle_date.to_date.to_s } } }
        let(:expected_moves) { first_moves + middle_moves }
        let(:unexpected_moves) { last_moves }

        it_behaves_like 'it returns the correct moves'
      end

      context 'when given bad start date' do
        let(:filter_params) { { filter: { created_at_from: 'rabbit' } } }
        let(:errors_422) do
          [{
             'title' => 'Invalid created_at_from',
             'detail' => 'Validation failed: Created at from is not a valid date.',
           }]
        end

        it_behaves_like 'an endpoint that responds with error 422'
      end

      context 'when given bad end date' do
        let(:filter_params) { { filter: { created_at_to: 'rabbit' } } }
        let(:errors_422) do
          [{
               'title' => 'Invalid created_at_to',
               'detail' => 'Validation failed: Created at to is not a valid date.',
           }]
        end

        it_behaves_like 'an endpoint that responds with error 422'
      end
    end

    describe 'by move_type' do
      let(:filter_params) { { filter: { move_type: move_type } } }
      let(:court_appearance_moves) { create_list :move, 3, :court_appearance }
      let(:prison_recall_moves) { create_list :move, 3, :prison_recall }
      let(:prison_transfer_moves) { create_list :move, 3, :prison_transfer }

      context 'when court_appearance' do
        let(:move_type) { 'court_appearance' }
        let(:expected_moves) { court_appearance_moves }
        let(:unexpected_moves) { prison_recall_moves + prison_transfer_moves }

        it_behaves_like 'it returns the correct moves'
      end

      context 'when prison_transfer' do
        let(:move_type) { 'prison_transfer' }
        let(:expected_moves) { prison_transfer_moves }
        let(:unexpected_moves) { court_appearance_moves + prison_recall_moves }

        it_behaves_like 'it returns the correct moves'
      end

      context 'when prison_recall' do
        let(:move_type) { 'prison_recall' }
        let(:expected_moves) { prison_recall_moves }
        let(:unexpected_moves) { court_appearance_moves + prison_transfer_moves }

        it_behaves_like 'it returns the correct moves'
      end
    end

    describe 'by cancellation_reason' do
      let(:filter_params) { { filter: { cancellation_reason: cancellation_reason } } }
      let(:made_in_error_moves) { create_list :move, 3, :cancelled_made_in_error }
      let(:supplier_declined_to_move_moves) { create_list :move, 3, :cancelled_supplier_declined_to_move }
      let(:rejected_moves) { create_list :move, 3, :cancelled_rejected }
      let(:other_moves) { create_list :move, 3, :cancelled_other }

      context 'when made_in_error' do
        let(:cancellation_reason) { 'made_in_error' }
        let(:expected_moves) { made_in_error_moves }
        let(:unexpected_moves) { supplier_declined_to_move_moves + rejected_moves + other_moves }

        it_behaves_like 'it returns the correct moves'
      end

      context 'when supplier_declined_to_move' do
        let(:cancellation_reason) { 'supplier_declined_to_move' }
        let(:expected_moves) { supplier_declined_to_move_moves }
        let(:unexpected_moves) { made_in_error_moves + rejected_moves + other_moves }

        it_behaves_like 'it returns the correct moves'
      end

      context 'when rejected' do
        let(:cancellation_reason) { 'rejected' }
        let(:expected_moves) { rejected_moves }
        let(:unexpected_moves) { made_in_error_moves + supplier_declined_to_move_moves + other_moves }

        it_behaves_like 'it returns the correct moves'
      end

      context 'when other' do
        let(:cancellation_reason) { 'other' }
        let(:expected_moves) { other_moves }
        let(:unexpected_moves) { made_in_error_moves + supplier_declined_to_move_moves + rejected_moves }

        it_behaves_like 'it returns the correct moves'
      end
    end
  end
end
