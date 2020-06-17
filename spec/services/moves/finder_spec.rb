# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::Finder do
  subject(:results) { described_class.new(filter_params, ability, order_params).call }

  let(:filter_params) { {} }
  let(:application) { Doorkeeper::Application.new(name: 'test') }
  let(:ability) { Ability.new(application) }
  let(:order_params) { {} }

  describe 'filtering' do
    context 'with no filters' do
      let(:move) { create :move, :prison_recall }
      let!(:proposed_move) { create :move, :proposed }
      let!(:cancelled_supplier_declined_to_move) { create :move, :cancelled_supplier_declined_to_move }
      let!(:completed_move) { create :move, :completed }
      let!(:move_with_allocation) { create(:move, :with_allocation) }
      let(:filter_params) { {} }

      it 'returns all moves' do
        expect(results).to match_array [move, proposed_move, cancelled_supplier_declined_to_move, completed_move, move_with_allocation]
      end
    end

    describe 'by from_location_id' do
      let!(:move) { create :move }

      context 'with matching location filter' do
        let(:filter_params) { { from_location_id: [move.from_location_id] } }

        it 'returns moves matching from location' do
          expect(results).to match_array [move]
        end
      end

      context 'with two location filters' do
        let!(:second_move) { create :from_court_to_prison }
        let(:filter_params) { { from_location_id: [move.from_location_id, second_move.from_location_id] } }

        it 'returns moves matching multiple locations' do
          expect(results).to match_array [move, second_move]
        end
      end

      context 'with mis-matching location filter' do
        let(:filter_params) { { from_location_id: Random.uuid } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by location_type' do
      let!(:move) { create :move }

      context 'with matching location type' do
        let(:filter_params) { { location_type: move.to_location.location_type } }

        it 'returns moves matching location type' do
          expect(results).to match_array [move]
        end
      end

      context 'with mis-matching location type' do
        let(:filter_params) { { location_type: 'hospital' } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by supplier_id' do
      context 'with supplier filter' do
        let(:supplier) { create :supplier }
        let!(:location) { create :location, :with_moves, suppliers: [supplier] }
        let(:filter_params) { { supplier_id: supplier.id } }

        it 'returns moves matching the supplier' do
          expect(results).to match_array location.moves_from
        end
      end
    end

    describe 'by dates' do
      let!(:move) { create :move }

      context 'with matching date range' do
        let!(:move_5_days_future) { create(:move, date: move.date + 5.days) }
        let(:filter_params) { { date_from: move.date.to_s, date_to: (move.date + 5.days).to_s } }

        before do
          create(:move, date: move.date + 6.days)
          create(:move, date: move.date - 1.day)
        end

        it 'returns moves matching date range' do
          expect(results).to match_array [move, move_5_days_future]
        end
      end

      context 'with mis-matching mismatched date range in past' do
        let(:filter_params) { { date_from: (move.date - 5.days).to_s, date_to: (move.date - 2.days).to_s } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end

      context 'with mis-matching mismatched date range in future' do
        let(:filter_params) { { date_from: (move.date + 2.days).to_s, date_to: (move.date + 5.days).to_s } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by move status' do
      let!(:proposed_move) { create :move, :proposed }
      let!(:requested_move) { create :move, :requested }
      let!(:booked_move) { create :move, :booked }
      let!(:cancelled_move) { create :move, :cancelled }
      let!(:completed_move) { create :move, :completed }

      context 'with matching status' do
        let(:filter_params) { { status: 'proposed' } }

        it 'returns moves matching status' do
          expect(results).to match_array [proposed_move]
        end
      end

      context 'with multiple statuses' do
        let(:filter_params) { { status: 'requested,completed,booked' } }

        it 'returns moves matching status' do
          expect(results).to match_array [requested_move, completed_move, booked_move]
        end
      end

      context 'with mis-matching status' do
        let(:filter_params) { { status: 'fruit bats' } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by move_type' do
      let!(:court_appearance_move) { create :move, :court_appearance }
      let!(:prison_recall_move) { create :move, :prison_recall }
      let!(:prison_transfer_move) { create :move, :prison_transfer }

      context 'with matching move_type' do
        let(:filter_params) { { move_type: 'court_appearance' } }

        it 'returns moves matching type' do
          expect(results).to match_array [court_appearance_move]
        end
      end

      context 'with multiple move_types' do
        let(:filter_params) { { move_type: 'prison_transfer,prison_recall' } }

        it 'returns moves matching status' do
          expect(results).to match_array [prison_recall_move, prison_transfer_move]
        end
      end

      context 'with mis-matching move_type' do
        let(:filter_params) { { move_type: 'fruit bats' } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by cancellation_reason' do
      let!(:cancelled_made_in_error_move) { create :move, :cancelled_made_in_error }
      let!(:cancelled_supplier_declined_to_move_move) { create :move, :cancelled_supplier_declined_to_move }
      let!(:cancelled_rejected_move) { create :move, :cancelled_rejected }
      let!(:cancelled_other_move) { create :move, :cancelled_other }

      context 'with matching cancellation_reason' do
        let(:filter_params) { { cancellation_reason: 'other' } }

        it 'returns moves matching type' do
          expect(results).to match_array [cancelled_other_move]
        end
      end

      context 'with multiple cancellation_reasons' do
        let(:filter_params) { { cancellation_reason: 'made_in_error,rejected' } }

        it 'returns moves matching status' do
          expect(results).to match_array [cancelled_made_in_error_move, cancelled_rejected_move]
        end
      end

      context 'with mis-matching cancellation_reason' do
        let(:filter_params) { { cancellation_reason: 'fruit bats' } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by has_relationship_to_allocation' do
      let!(:move_with_allocation) { create(:move, :with_allocation) }
      let!(:move_without_allocation) { create(:move) }

      context 'with wrong type passed to has_relationship_to_allocation filter' do
        let(:filter_params) { { has_relationship_to_allocation: Random.uuid } }

        it 'returns all moves' do
          expect(results).to contain_exactly(move_with_allocation, move_without_allocation)
        end
      end

      context 'with has_relationship_to_allocation set as `nil`' do
        let(:filter_params) { { has_relationship_to_allocation: nil } }

        it 'returns all moves' do
          expect(results).to contain_exactly(move_with_allocation, move_without_allocation)
        end
      end

      context 'with has_relationship_to_allocation set as `false`' do
        let(:filter_params) { { has_relationship_to_allocation: 'false' } }

        it 'returns only moves without allocations' do
          expect(results).to contain_exactly(move_without_allocation)
        end
      end

      context 'with has_relationship_to_allocation set as `true`' do
        let(:filter_params) { { has_relationship_to_allocation: 'true' } }

        it 'returns only moves with allocations' do
          expect(results).to contain_exactly(move_with_allocation)
        end
      end
    end

    describe 'sort order' do
      let(:location1) { create :location, title: 'LOCATION1' }
      let(:location2) { create :location, title: 'Location2' }
      let(:location3) { create :location, title: 'LOCATION3' }
      let!(:moves) do
        create :move, to_location: location1
        create :move, to_location: location2
        create :move, to_location: location3
      end
      let(:order_params) { { by: :to_location, direction: :asc } }

      it 'ordered by location (case-sensitive)' do
        expect(results.map(&:to_location).pluck(:title)).to eql(%w[LOCATION1 LOCATION3 Location2]) # NB: case-sensitive order
      end
    end
  end
end
