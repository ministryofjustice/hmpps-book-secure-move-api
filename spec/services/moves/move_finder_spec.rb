# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::MoveFinder do
  subject(:move_finder) { described_class.new(filter_params) }

  let!(:move) { create :move }
  let(:move_id) { move.id }
  let(:filter_params) { {} }

  describe 'filtering' do
    context 'with matching location filter' do
      let(:filter_params) { { from_location_id: move.from_location_id } }

      it 'returns moves matching from location' do
        expect(move_finder.call.pluck(:id)).to eql [move.id]
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
end
