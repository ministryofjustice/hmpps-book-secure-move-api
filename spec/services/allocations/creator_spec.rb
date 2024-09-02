# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Allocations::Creator do
  subject(:call_creator) { creator.call }

  before do
    allow(SupplierChooser).to receive(:new).and_return(instance_double(SupplierChooser, call: supplier))
  end

  let(:creator) do
    described_class.new(
      doorkeeper_application_owner:,
      allocation_params:,
      complex_case_params:,
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

  let(:doorkeeper_application_owner) { nil }
  let!(:from_location) { create(:location, :with_suppliers) }
  let!(:to_location) { create(:location) }
  let!(:supplier) { from_location&.suppliers&.first }
  let(:date) { Time.zone.today }
  let(:moves_count) { 2 }
  let(:requested_by) { 'Iama Requestor' }
  let(:allocation_params) do
    {
      type: 'allocations',
      attributes: {
        date:,
        moves_count:,
        estate: :adult_female,
        prisoner_category: :b,
        sentence_length: :other,
        sentence_length_comment: '30 years',
        other_criteria: 'curly hair',
        requested_by:,
        complete_in_full: true,
        complex_cases: complex_case_params,
      },
      relationships: {
        from_location: { data: { type: 'locations', id: from_location&.id } },
        to_location: { data: { type: 'locations', id: to_location&.id } },
      },
    }
  end

  context 'with valid params' do
    it 'creates an allocation' do
      call_creator
      expect(creator.allocation).to be_persisted
    end

    it 'sets the correct attributes to an allocation' do
      call_creator
      expect(creator.allocation).to have_attributes(
        status: 'unfilled',
        date:,
        moves_count: 2,
        prisoner_category: 'b',
        sentence_length: 'other',
        sentence_length_comment: '30 years',
        estate: 'adult_female',
        other_criteria: 'curly hair',
        requested_by: 'Iama Requestor',
        complete_in_full: true,
        to_location:,
        from_location:,
      )
    end

    it 'creates the same number of associated moves as `moves_count`' do
      expect { call_creator }.to change(Move, :count).by(2)
    end

    it 'sets the correct attributes to associated moves' do
      call_creator
      expect(creator.allocation.moves.first).to have_attributes(
        date:,
        to_location:,
        from_location:,
        status: 'requested',
        move_type: 'prison_transfer',
      )
    end

    it 'creates the same number of GenericEvent::MoveRequested events as `moves_count`' do
      expect { call_creator }.to change(GenericEvent::MoveRequested, :count).by(2)
    end

    it 'sets the correct attributes of associated MoveRequested events' do
      call_creator
      expect(creator.allocation.moves.first.generic_events.first).to have_attributes(
        type: 'GenericEvent::MoveRequested',
        eventable_id: creator.allocation.moves.first.id,
        eventable_type: 'Move',
        notes: 'Automatically generated for allocation',
        created_by: 'Iama Requestor',
        supplier_id: nil,
      )
    end

    it 'sets the correct number of complex_cases' do
      call_creator
      expect(creator.allocation.complex_cases.size).to eq(2)
    end

    it 'sets the correct attributes for complex case answers' do
      call_creator
      expect(creator.allocation.complex_cases.first).to have_attributes(
        key: complex_case1.key,
        title: complex_case1.title,
        answer: false,
        allocation_complex_case_id: complex_case1.id,
      )
    end

    context 'with valid doorkeeper_application_owner' do
      let(:api_supplier) { create(:supplier) }
      let(:doorkeeper_application_owner) { api_supplier }

      it 'sets the allocation moves supplier from api token' do
        call_creator
        expect(creator.allocation.moves.pluck(:supplier_id).uniq).to contain_exactly(api_supplier.id)
      end

      it 'does not call the SupplierChooser service' do
        call_creator
        expect(SupplierChooser).not_to have_received(:new)
      end
    end

    context 'with nil doorkeeper_application_owner' do
      it 'sets the allocation moves supplier via SupplierChooser service' do
        call_creator
        expect(creator.allocation.moves.pluck(:supplier_id).uniq).to contain_exactly(supplier.id)
      end

      it 'calls the SupplierChooser service with the correct args' do
        call_creator
        expect(SupplierChooser).to have_received(:new).with(creator.allocation)
      end
    end

    context 'when specifying nil complex_cases attribute' do
      let(:complex_case_params) { nil }

      it 'creates an allocation without complex cases' do
        call_creator
        expect(creator.allocation.complex_cases).to be_empty
      end
    end

    context 'with nil requested_by attribute' do
      let(:requested_by) { nil }

      it 'creates an allocation without requested_by' do
        call_creator
        expect(creator.allocation.requested_by).to be_nil
      end
    end
  end

  context 'with invalid input params' do
    context 'with a missing location' do
      let(:from_location) { nil }

      it 'raises an error' do
        expect { call_creator }.to raise_error(
          ActiveRecord::RecordNotFound,
          "Couldn't find Location without an ID",
        )
      end
    end

    context 'with incorrect moves_count type' do
      let(:moves_count) { '27.5' }

      it 'raises an error' do
        expect { call_creator }.to raise_error(
          ActiveRecord::RecordInvalid,
          'Validation failed: Moves count must be an integer',
        )
      end
    end

    context 'with zero moves_count' do
      let(:moves_count) { 0 }

      it 'raises an error' do
        expect { call_creator }.to raise_error(
          ActiveRecord::RecordInvalid,
          'Validation failed: Moves count must be greater than 0',
        )
      end
    end

    context 'with missing params' do
      let(:date) { nil }

      it 'raises an error' do
        expect { call_creator }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'makes the allocation validation errors available via exception' do
        call_creator
      rescue ActiveRecord::RecordInvalid => e
        expect(e.record.errors.messages[:date]).to eq(["can't be blank"])
      end

      it 'does not attempt to create a move' do
        call_creator
      rescue ActiveRecord::RecordInvalid => e
        expect(e.record.moves).to be_empty
      end
    end
  end
end
