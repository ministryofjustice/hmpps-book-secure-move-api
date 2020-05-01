# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Allocations::Finder do
  subject(:allocation_finder) { described_class.new(filter_params) }

  let!(:from_location) { create :location }
  let!(:to_location) { create :location }
  let!(:allocation) { create :allocation, from_location: from_location, to_location: to_location }
  let(:filter_params) { {} }

  describe 'filtering' do
    context 'with matching date range' do
      before do
        create(:allocation, date: allocation.date + 6.days)
        create(:allocation, date: allocation.date - 1.day)
      end

      let!(:allocation_5_days_future) { create(:allocation, date: allocation.date + 5.days) }
      let(:filter_params) { { date_from: allocation.date.to_s, date_to: (allocation.date + 5.days).to_s } }

      it 'returns allocations matching date range' do
        expect(allocation_finder.call).to match_array [allocation, allocation_5_days_future]
      end
    end

    context 'with mis-matching mismatched date range in past' do
      let(:filter_params) { { date_from: (allocation.date - 5.days).to_s, date_to: (allocation.date - 2.days).to_s } }

      it 'returns empty result set' do
        expect(allocation_finder.call).to be_empty
      end
    end

    context 'with mis-matching mismatched date range in future' do
      let(:filter_params) { { date_from: (allocation.date + 2.days).to_s, date_to: (allocation.date + 5.days).to_s } }

      it 'returns empty result set' do
        expect(allocation_finder.call).to be_empty
      end
    end

    context 'with matching from_locations' do
      let!(:other_allocation) { create(:allocation, to_location: to_location) }
      let(:filter_params) { { from_locations: from_location.id } }

      it 'returns allocations matching specified from_location' do
        expect(allocation_finder.call).to match_array [allocation]
      end
    end

    context 'with matching to_locations' do
      let!(:other_allocation) { create(:allocation, from_location: from_location) }
      let(:filter_params) { { to_locations: to_location.id } }

      it 'returns allocations matching specified to_location' do
        expect(allocation_finder.call).to match_array [allocation]
      end
    end

    context 'with matching from_locations and to_locations' do
      let!(:other_allocation) { create(:allocation) }
      let(:filter_params) { { from_locations: from_location.id, to_locations: to_location.id } }

      it 'returns allocations matching specified from_location and to_location' do
        expect(allocation_finder.call).to match_array [allocation]
      end
    end

    context 'with matching locations' do
      let!(:shared_location) { create :location }
      let!(:allocation) { create(:allocation, from_location: shared_location) }
      let!(:other_allocation) { create(:allocation, to_location: shared_location) }
      let!(:unmatched_allocation) { create(:allocation) }
      let(:filter_params) { { locations: shared_location.id } }

      it 'returns allocations matching specified from_location or to_location' do
        expect(allocation_finder.call).to match_array [allocation, other_allocation]
      end
    end

    context 'with multiple matching from_locations' do
      let!(:other_location) { create(:location) }
      let!(:other_allocation) { create(:allocation, from_location: other_location) }
      let(:filter_params) { { from_locations: [from_location.id, other_location.id] } }

      it 'returns allocations matching either specified from_location' do
        expect(allocation_finder.call).to match_array [allocation, other_allocation]
      end
    end

    context 'with multiple matching to_locations' do
      let!(:other_location) { create(:location) }
      let!(:other_allocation) { create(:allocation, to_location: other_location) }
      let(:filter_params) { { to_locations: [to_location.id, other_location.id] } }

      it 'returns allocations matching either specified to_location' do
        expect(allocation_finder.call).to match_array [allocation, other_allocation]
      end
    end

    context 'with multiple matching locations' do
      let!(:other_location) { create(:location) }
      let!(:other_allocation) { create(:allocation, to_location: other_location) }
      let(:filter_params) { { locations: [from_location.id, other_location.id] } }

      it 'returns allocations matching either specified from_location or to_location' do
        expect(allocation_finder.call).to match_array [allocation, other_allocation]
      end
    end
  end
end
