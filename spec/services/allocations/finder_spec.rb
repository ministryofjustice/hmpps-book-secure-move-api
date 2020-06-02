# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Allocations::Finder do
  subject(:allocation_finder) { described_class.new(filter_params, sort_params) }

  let!(:from_location) { create :location }
  let!(:to_location) { create :location }

  let!(:allocation) { create :allocation, :none, from_location: from_location, to_location: to_location }
  let(:filter_params) { {} }
  let(:sort_params) { {} }

  describe 'filtering' do
    context 'with matching date range' do
      before do
        create(:allocation, date: allocation.date + 6.days)
        create(:allocation, date: allocation.date - 1.day)
      end

      let!(:allocation_5_days_future) { create(:allocation, date: allocation.date + 5.days) }
      let(:filter_params) { { date_from: allocation.date.to_s, date_to: (allocation.date + 5.days).to_s } }

      it 'returns allocations matching date range sorted by descending date' do
        expect(allocation_finder.call).to eq [allocation_5_days_future, allocation]
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
        expect(allocation_finder.call).to contain_exactly(allocation)
      end
    end

    context 'with matching to_locations' do
      let!(:other_allocation) { create(:allocation, from_location: from_location) }
      let(:filter_params) { { to_locations: to_location.id } }

      it 'returns allocations matching specified to_location' do
        expect(allocation_finder.call).to contain_exactly(allocation)
      end
    end

    context 'with matching from_locations and to_locations' do
      let!(:other_allocation) { create(:allocation) }
      let(:filter_params) { { from_locations: from_location.id, to_locations: to_location.id } }

      it 'returns allocations matching specified from_location and to_location' do
        expect(allocation_finder.call).to contain_exactly(allocation)
      end
    end

    context 'with matching locations' do
      let!(:shared_location) { create :location }
      let!(:allocation) { create(:allocation, from_location: shared_location) }
      let!(:other_allocation) { create(:allocation, to_location: shared_location) }
      let!(:unmatched_allocation) { create(:allocation) }
      let(:filter_params) { { locations: shared_location.id } }

      it 'returns allocations matching specified from_location or to_location' do
        expect(allocation_finder.call).to contain_exactly(allocation, other_allocation)
      end
    end

    context 'with multiple matching from_locations' do
      let!(:other_location) { create(:location) }
      let!(:other_allocation) { create(:allocation, from_location: other_location) }
      let(:filter_params) { { from_locations: [from_location.id, other_location.id] } }

      it 'returns allocations matching either specified from_location' do
        expect(allocation_finder.call).to contain_exactly(allocation, other_allocation)
      end
    end

    context 'with multiple matching to_locations' do
      let!(:other_location) { create(:location) }
      let!(:other_allocation) { create(:allocation, to_location: other_location) }
      let(:filter_params) { { to_locations: [to_location.id, other_location.id] } }

      it 'returns allocations matching either specified to_location' do
        expect(allocation_finder.call).to contain_exactly(allocation, other_allocation)
      end
    end

    context 'with multiple matching locations' do
      let!(:other_location) { create(:location) }
      let!(:other_allocation) { create(:allocation, to_location: other_location) }
      let(:filter_params) { { locations: [from_location.id, other_location.id] } }

      it 'returns allocations matching either specified from_location or to_location' do
        expect(allocation_finder.call).to contain_exactly(allocation, other_allocation)
      end
    end

    describe 'by status' do
      let!(:unfilled_allocation) { create :allocation, :unfilled, from_location: from_location, to_location: to_location }
      let!(:filled_allocation) { create :allocation, :filled, from_location: from_location, to_location: to_location }
      let!(:cancelled_allocation) { create :allocation, :cancelled, from_location: from_location, to_location: to_location }

      context 'with matching status' do
        let(:filter_params) { { status: 'filled' } }

        it 'returns allocations matching status' do
          expect(allocation_finder.call).to contain_exactly(filled_allocation)
        end
      end

      context 'with multiple statuses' do
        let(:filter_params) { { status: 'unfilled,cancelled' } }

        it 'returns allocations matching status' do
          expect(allocation_finder.call).to contain_exactly(unfilled_allocation, cancelled_allocation)
        end
      end

      context 'with mis-matching status' do
        let(:filter_params) { { status: 'foo' } }

        it 'returns empty results set' do
          expect(allocation_finder.call).to be_empty
        end
      end

      context 'with nil status' do
        let(:filter_params) { { status: nil } }

        it 'returns only allocations without a status' do
          expect(allocation_finder.call).to contain_exactly(allocation)
        end
      end
    end
  end

  describe 'sorting' do
    let(:location1) { create :location, title: 'LOCATION1' }
    let(:location2) { create :location, title: 'Location2' }
    let(:location3) { create :location, title: 'LOCATION3' }

    context 'when by from_location' do
      let!(:allocation) { create :allocation, from_location: location1, to_location: to_location }
      let!(:allocation2) { create :allocation, from_location: location2, to_location: to_location }
      let!(:allocation3) { create :allocation, from_location: location3, to_location: to_location }

      let(:sort_params) { { by: :from_location, direction: :asc } }

      it 'orders by location title (case-sensitive)' do
        expect(allocation_finder.call.map(&:from_location).pluck(:title)).to eql(%w[LOCATION1 LOCATION3 Location2])
      end
    end

    context 'when by to_location' do
      let!(:allocation) { create :allocation, from_location: from_location, to_location: location1 }
      let!(:allocation2) { create :allocation, from_location: from_location, to_location: location2 }
      let!(:allocation3) { create :allocation, from_location: from_location, to_location: location3 }

      let(:sort_params) { { by: :to_location, direction: :asc } }

      it 'orders by location title (case-sensitive)' do
        expect(allocation_finder.call.map(&:to_location).pluck(:title)).to eql(%w[LOCATION1 LOCATION3 Location2])
      end
    end

    context 'when by moves_count' do
      let!(:allocation) { create :allocation, moves_count: 1, from_location: from_location, to_location: to_location }
      let!(:allocation2) { create :allocation, moves_count: 2, from_location: from_location, to_location: to_location }
      let!(:allocation3) { create :allocation, moves_count: 3, from_location: from_location, to_location: to_location }

      let(:sort_params) { { by: :moves_count, direction: :desc } }

      it 'orders by allocation moves count' do
        expect(allocation_finder.call.pluck(:moves_count)).to eql([3, 2, 1])
      end
    end

    context 'when by date' do
      let!(:allocation2) { create :allocation, date: allocation.date + 2.days, from_location: from_location, to_location: to_location }
      let!(:allocation3) { create :allocation, date: allocation.date + 5.days, from_location: from_location, to_location: to_location }

      let(:sort_params) { { by: :date, direction: :desc } }

      it 'orders by allocation date' do
        expect(allocation_finder.call).to eq([allocation3, allocation2, allocation])
      end
    end
  end
end
