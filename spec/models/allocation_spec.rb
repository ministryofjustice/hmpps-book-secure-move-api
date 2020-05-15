# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Allocation do
  it { is_expected.to belong_to(:from_location) }
  it { is_expected.to belong_to(:to_location) }

  it { is_expected.to have_many(:moves) }
  it { is_expected.to have_many(:events) }

  it { is_expected.to validate_presence_of(:from_location) }
  it { is_expected.to validate_presence_of(:to_location) }

  it { is_expected.to allow_value(nil).for(:prisoner_category) }
  it { is_expected.to define_enum_for(:prisoner_category).backed_by_column_of_type(:string) }
  it { is_expected.to allow_value(nil).for(:sentence_length) }
  it { is_expected.to define_enum_for(:sentence_length).backed_by_column_of_type(:string) }

  it { is_expected.to allow_value(nil).for(:status) }
  it { is_expected.to define_enum_for(:status).backed_by_column_of_type(:string) }

  it { is_expected.to validate_presence_of(:moves_count) }
  it { is_expected.to validate_numericality_of(:moves_count) }
  it { is_expected.to validate_presence_of(:date) }

  context 'with versioning' do
    let(:allocation) { create(:allocation) }

    it 'has a version record for the create' do
      expect(allocation.versions.map(&:event)).to eq(%w[create])
    end
  end

  describe 'cancellation_reason' do
    context 'when the allocation is not cancelled' do
      let(:allocation) { build(:allocation, status: nil) }

      it { expect(allocation).to validate_absence_of(:cancellation_reason) }
    end

    context 'when the allocation is cancelled' do
      let(:allocation) { build(:allocation, status: 'cancelled') }

      it {
        expect(allocation).to validate_inclusion_of(:cancellation_reason)
          .in_array(%w[
            made_in_error
            supplier_declined_to_move
            other
            lack_of_space_at_receiving_establishment
            sending_establishment_failed_to_fill_allocation
          ])
      }
    end
  end

  describe '#cancel' do
    let(:allocation) { create(:allocation, :with_moves, status: nil) }

    it 'changes the status of an allocation to cancelled' do
      allocation.reload.cancel

      expect(allocation.reload.status).to eq(described_class::ALLOCATION_STATUS_CANCELLED)
    end

    it 'changes the status of all associated moves to cancelled' do
      allocation.reload.cancel

      expect(allocation.reload.moves.pluck(:status)).to contain_exactly(Move::MOVE_STATUS_CANCELLED)
    end

    it 'sets the cancellation reason to other' do
      allocation.reload.cancel

      expect(allocation.reload.cancellation_reason).to eq(described_class::CANCELLATION_REASON_OTHER)
    end

    it 'sets the cancellation reason comment to cancelled by allocation' do
      allocation.reload.cancel

      expect(allocation.reload.cancellation_reason_comment).to eq('Allocation was cancelled')
    end

    it 'sets the cancellation reason on moves to other' do
      allocation.reload.cancel

      expect(allocation.reload.moves.first.cancellation_reason).to eq(Move::CANCELLATION_REASON_OTHER)
    end

    it 'sets the cancellation reason comment on moves to cancelled by allocation' do
      allocation.reload.cancel

      expect(allocation.reload.moves.first.cancellation_reason_comment).to eq('Allocation was cancelled')
    end

    it 'throws validation error if allocation invalid' do
      allocation.from_location = nil

      expect { allocation.cancel }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'does not update moves if allocation invalid' do
      allocation.from_location = nil
      allocation.cancel
    rescue ActiveRecord::RecordInvalid
      expect(allocation.reload.moves.pluck(:status)).to contain_exactly(Move::MOVE_STATUS_REQUESTED)
    end
  end
end
