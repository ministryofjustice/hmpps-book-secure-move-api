# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Allocations::Finder do
  subject(:allocation_finder) { described_class.new(filter_params) }

  let!(:allocation) { create :allocation }
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
  end
end
