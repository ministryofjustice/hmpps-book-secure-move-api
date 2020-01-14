# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::Finder do
  subject(:move_finder) { described_class.new(filter_params) }

  let!(:move) { create :move }
  let(:move_id) { move.id }
  let(:filter_params) { {} }

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
      let(:filter_params) { {} }

      it 'returns all moves' do
        expect(move_finder.call.pluck(:id)).to eql [move.id]
      end
    end

    context 'with mis-matching location filter' do
      let(:filter_params) { { location_type: 'hospital' } }

      it 'returns empty result set' do
        expect(move_finder.call.to_a).to eql []
      end
    end

    context 'with matching date range' do
      let(:filter_params) { { date_from: Date.today.to_s, date_to: 5.days.from_now.to_date.to_s } }

      it 'returns moves matching date range' do
        expect(move_finder.call.pluck(:id)).to eql [move.id]
      end
    end

    context 'with mis-matching mismatched date range in past' do
      let(:filter_params) { { date_from: 5.days.ago.to_date.to_s, date_to: 2.days.ago.to_date.to_s } }

      it 'returns empty result set' do
        expect(move_finder.call.to_a).to eql []
      end
    end

    context 'with mis-matching mismatched date range in future' do
      let(:filter_params) { { date_from: 2.days.from_now.to_date.to_s, date_to: 5.days.from_now.to_date.to_s } }

      it 'returns empty result set' do
        expect(move_finder.call.to_a).to eql []
      end
    end

    context 'with matching status' do
      let(:filter_params) { { status: move.status } }

      it 'returns moves matching status' do
        expect(move_finder.call.pluck(:id)).to eql [move.id]
      end
    end

    context 'with mis-matching ' do
      let(:filter_params) { { status: 'not_a_status' } }

      it 'returns empty result set' do
        expect(move_finder.call.to_a).to eql []
      end
    end
  end

  describe 'ordering' do
    let(:prison) { create :location }
    let!(:move_to_prison) { create :move, to_location: prison }

    it 'returns moves in the correct order' do
      expect(move_finder.call.pluck(:id)).to eql [move.id, move_to_prison.id].sort
    end
  end
end
