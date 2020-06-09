# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Allocations::Creator do
  subject(:creator) do
    described_class.new(
      allocation_params: allocation_params,
      complex_case_params: complex_case_params,
    )
  end

  let!(:complex_case1) { create(:allocation_complex_case) }
  let!(:complex_case2) { create(:allocation_complex_case, :self_harm) }

  let(:complex_case_params) do
    [
      {
        key: complex_case1.key,
        title: complex_case1.title,
        answer: false,
        allocation_complex_case_id: complex_case1.id,
      },
      {
        key: complex_case2.key,
        title: complex_case2.title,
        answer: true,
        allocation_complex_case_id: complex_case2.id,
      },
    ]
  end

  let!(:from_location) { create(:location) }
  let!(:to_location) { create(:location) }
  let(:date) { Date.today }
  let(:allocation_params) do
    {
      type: 'allocations',
      attributes: {
        date: date,
        moves_count: 2,
        prisoner_category: :b,
        sentence_length: :short,
        other_criteria: 'curly hair',
        complete_in_full: true,
        complex_cases: complex_case_params,
      },
      relationships: {
        from_location: { data: { type: 'locations', id: from_location&.id } },
        to_location: { data: { type: 'locations', id: to_location&.id } },
      },
    }
  end

  before do
    next if RSpec.current_example.metadata[:skip_before]

    creator.call
  end

  context 'with valid params' do
    it 'creates an allocation' do
      expect(creator.allocation).to be_persisted
    end

    it 'sets the correct attributes to an allocation' do
      expect(creator.allocation).to have_attributes(
        date: date,
        moves_count: 2,
        prisoner_category: 'b',
        sentence_length: 'short',
        other_criteria: 'curly hair',
        complete_in_full: true,
        to_location: to_location,
        from_location: from_location,
      )
    end

    it 'creates associates moves to the same number as `moves_count`', :skip_before do
      expect { creator.call }.to change(Move, :count).by(2)
    end

    it 'sets the correct attributes to associated moves' do
      expect(creator.allocation.moves.first).to have_attributes(
        date: date,
        to_location: to_location,
        from_location: from_location,
        status: 'requested',
      )
    end

    it 'sets the correct number of complex_cases' do
      expect(creator.allocation.complex_cases.size).to eq(2)
    end

    it 'sets the correct attributes for complex case answers' do
      expect(creator.allocation.complex_cases.first).to have_attributes(
        key: complex_case1.key,
        title: complex_case1.title,
        answer: false,
        allocation_complex_case_id: complex_case1.id,
      )
    end

    context 'when specifying nil complex_cases attribute' do
      let(:complex_case_params) { nil }

      it 'creates an allocation without complex cases' do
        expect(creator.allocation.complex_cases).to be_empty
      end
    end
  end

  context 'with invalid input params' do
    context 'with a missing location' do
      let(:from_location) { nil }

      it 'raises an error', :skip_before do
        expect { creator.call }.to raise_error(
          ActiveRecord::RecordNotFound,
          "Couldn't find Location without an ID",
        )
      end
    end

    context 'with missing params' do
      let(:date) { nil }

      it 'raises an error', :skip_before do
        expect { creator.call }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'makes the allocation validation errors available via exception', :skip_before do
        creator.call
      rescue ActiveRecord::RecordInvalid => e
        expect(e.record.errors.messages).to include(date: ["can't be blank"])
      end

      it 'does not attempt to create a move', :skip_before do
        creator.call
      rescue ActiveRecord::RecordInvalid => e
        expect(e.record.moves).to be_empty
      end
    end
  end
end
