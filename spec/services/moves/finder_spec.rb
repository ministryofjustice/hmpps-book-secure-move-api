# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::Finder do
  subject(:move_finder) { described_class.new(filter_params, ability, {}) }

  let!(:move) { create :move }
  let(:move_id) { move.id }
  let(:filter_params) { {} }
  let(:application) { Doorkeeper::Application.new(name: 'test') }
  let(:ability) { Ability.new(application) }

  describe 'filtering' do
    context 'with matching location filter' do
      let(:filter_params) { { from_location_id: [move.from_location_id] } }

      it 'returns moves matching from location' do
        expect(move_finder.call.pluck(:id)).to eql [move.id]
      end
    end

    context 'with two location filters' do
      let!(:second_move) { create :from_court_to_prison }
      let(:filter_params) { { from_location_id: [move.from_location_id, second_move.from_location_id] } }

      it 'returns moves matching multiple locations' do
        expect(move_finder.call.pluck(:id).sort).to eql [move.id, second_move.id].sort
      end
    end

    context 'with supplier filter' do
      let(:supplier) { create :supplier }
      let!(:location) { create :location, :with_moves, suppliers: [supplier] }
      let(:filter_params) { { supplier_id: supplier.id } }

      it 'returns moves matching the supplier' do
        expect(move_finder.call.pluck(:id).sort).to eql location.moves_from.pluck(:id).sort
      end
    end

    context 'with mis-matching location filter' do
      let(:filter_params) { { from_location_id: Random.uuid } }

      it 'returns empty result set' do
        expect(move_finder.call.to_a).to eql []
      end
    end

    context 'with matching location type' do
      let(:filter_params) { { location_type: move.to_location.location_type } }

      it 'returns moves matching location type' do
        expect(move_finder.call.pluck(:id)).to eql [move.id]
      end
    end

    context 'with no location type and no location' do
      let!(:move) { create :move, move_type: 'prison_recall', to_location: nil }
      let!(:cancelled_move) { create :move, status: 'cancelled' }
      let!(:completed_move) { create :move, status: 'completed' }

      let(:filter_params) { {} }

      it 'returns all moves' do
        expect(move_finder.call).to match_array [move, cancelled_move, completed_move]
      end
    end

    context 'with mis-matching location filter' do
      let(:filter_params) { { location_type: 'hospital' } }

      it 'returns empty result set' do
        expect(move_finder.call).to be_empty
      end
    end

    context 'with matching date range' do
      before do
        create(:move, date: move.date + 6.days)
        create(:move, date: move.date - 1.day)
      end

      let!(:move_5_days_future) { create(:move, date: move.date + 5.days) }
      let(:filter_params) { { date_from: move.date.to_s, date_to: (move.date + 5.days).to_s } }

      it 'returns moves matching date range' do
        expect(move_finder.call).to match_array [move, move_5_days_future]
      end
    end

    context 'with mis-matching mismatched date range in past' do
      let(:filter_params) { { date_from: (move.date - 5.days).to_s, date_to: (move.date - 2.days).to_s } }

      it 'returns empty result set' do
        expect(move_finder.call).to be_empty
      end
    end

    context 'with mis-matching mismatched date range in future' do
      let(:filter_params) { { date_from: (move.date + 2.days).to_s, date_to: (move.date + 5.days).to_s } }

      it 'returns empty result set' do
        expect(move_finder.call).to be_empty
      end
    end

    context 'with matching status' do
      let(:filter_params) { { status: move.status } }

      it 'returns moves matching status' do
        expect(move_finder.call.pluck(:id)).to eql [move.id]
      end
    end

    context 'with multiple statuses' do
      let!(:cancelled_move) { create :move, status: 'cancelled' }
      let!(:completed_move) { create :move, status: 'completed' }
      let(:filter_params) { { status: [move.status, cancelled_move.status].join(',') } }

      it 'returns moves matching status' do
        expect(move_finder.call).to match_array [move, cancelled_move]
      end
    end

    context 'with mis-matching ' do
      let(:filter_params) { { status: 'not_a_status' } }

      it 'returns empty result set' do
        expect(move_finder.call.to_a).to eql []
      end
    end
  end
end
