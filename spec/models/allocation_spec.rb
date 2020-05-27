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

  describe '#refresh_status_and_moves_count!' do
    context 'when updating moves count' do
      let(:cancelled_move) { create :move, :cancelled }
      let(:proposed_move) { create :move, :proposed }
      let(:requested_move) { create :move, :requested }
      let(:completed_move) { create :move, :completed }
      let(:moves) { [cancelled_move, proposed_move, requested_move, completed_move] }
      let!(:allocation) { create :allocation, moves: moves, moves_count: 1 }

      it 'updates the number of non cancelled moves' do
        expect { allocation.refresh_status_and_moves_count! }.to change { allocation.reload.moves_count }.from(1).to(3)
      end
    end

    context 'when updating status' do
      it 'sets status to `unfilled` if no profiles associated with uncancelled moves' do
        moves = create_list(:move, 2, profile: nil)
        cancelled_move = create(:move, :cancelled)
        allocation = create(:allocation, moves: moves + [cancelled_move])

        allocation.refresh_status_and_moves_count!
        expect(allocation.reload).to be_unfilled
      end

      it 'sets status to `unfilled` if not all uncancelled moves are associated to profiles' do
        move_without_profile = create(:move, profile: nil)
        move_with_profile = create(:move)
        cancelled_move = create(:move, :cancelled)

        allocation = create(:allocation, moves: [move_without_profile, move_with_profile, cancelled_move])

        allocation.refresh_status_and_moves_count!
        expect(allocation.reload).to be_unfilled
      end

      it 'sets status to `filled` if all uncancelled moves are associated to profiles' do
        moves = create_list(:move, 2)
        cancelled_move = create(:move, :cancelled)

        allocation = create(:allocation, moves: moves + [cancelled_move])

        allocation.refresh_status_and_moves_count!
        expect(allocation.reload).to be_filled
      end

      it 'sets status to `unfilled` if all moves cancelled' do
        cancelled_move = create(:move, :cancelled)

        allocation = create(:allocation, moves: [cancelled_move])

        allocation.refresh_status_and_moves_count!
        expect(allocation.reload).to be_unfilled
      end
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

  describe '#cancel_with_moves' do
    let(:allocation) { create(:allocation, :with_moves, status: nil) }

    it 'changes the status of an allocation to cancelled' do
      allocation.reload.cancel_with_moves

      expect(allocation.reload.status).to eq(described_class::ALLOCATION_STATUS_CANCELLED)
    end

    it 'changes the moves_count of allocation to 0' do
      allocation.reload.cancel_with_moves

      expect(allocation.reload.moves_count).to eq(0)
    end

    it 'changes the status of all associated moves to cancelled' do
      allocation.reload.cancel_with_moves

      expect(allocation.reload.moves.pluck(:status)).to contain_exactly(Move::MOVE_STATUS_CANCELLED)
    end

    it 'sets the cancellation reason to other' do
      allocation.reload.cancel_with_moves

      expect(allocation.reload.cancellation_reason).to eq(described_class::CANCELLATION_REASON_OTHER)
    end

    it 'sets the cancellation reason comment to cancelled by allocation' do
      allocation.reload.cancel_with_moves

      expect(allocation.reload.cancellation_reason_comment).to eq('Allocation was cancelled')
    end

    it 'sets the cancellation reason on moves to other' do
      allocation.reload.cancel_with_moves

      expect(allocation.reload.moves.first.cancellation_reason).to eq(Move::CANCELLATION_REASON_OTHER)
    end

    it 'sets the cancellation reason comment on moves to cancelled by allocation' do
      allocation.reload.cancel_with_moves

      expect(allocation.reload.moves.first.cancellation_reason_comment).to eq('Allocation was cancelled')
    end

    it 'throws validation error if allocation invalid' do
      allocation.from_location = nil

      expect { allocation.cancel_with_moves }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'does not update moves if allocation invalid' do
      allocation.from_location = nil
      begin
        allocation.cancel_with_moves
      rescue StandardError
        ActiveRecord::RecordInvalid
      end

      expect(allocation.reload.moves.pluck(:status)).to contain_exactly(Move::MOVE_STATUS_REQUESTED)
    end
  end

  describe '#status' do
    it 'sets the initial status to unfilled' do
      allocation = create(:allocation)

      expect(allocation).to be_unfilled
    end

    it 'restores the current status if it is set' do
      allocation = create(:allocation, status: 'filled')

      expect(allocation).to be_filled
    end

    it 'updates the status from unfilled if it is filled' do
      allocation = create(:allocation, status: 'unfilled')

      allocation.fill
      expect(allocation).to be_filled
    end

    it 'updates the status from unfilled if it is cancelled' do
      allocation = create(:allocation, status: 'unfilled')

      allocation.cancel
      expect(allocation).to be_cancelled
    end

    it 'updates the status from filled if it is unfilled' do
      allocation = create(:allocation, status: 'filled')

      allocation.unfill
      expect(allocation).to be_unfilled
    end

    it 'updates the status from filled if it is cancelled' do
      allocation = create(:allocation, status: 'filled')

      allocation.cancel
      expect(allocation).to be_cancelled
    end

    it 'keeps the status filled if already set' do
      allocation = create(:allocation, status: 'filled')

      allocation.fill
      expect(allocation).to be_filled
    end

    it 'keeps the status unfilled if already set' do
      allocation = create(:allocation, status: 'unfilled')

      allocation.unfill
      expect(allocation).to be_unfilled
    end

    it 'updates the status from nil if it is filled' do
      allocation = create(:allocation, status: nil)

      allocation.fill
      expect(allocation).to be_filled
    end

    it 'updates the status from nil if it is unfilled' do
      allocation = create(:allocation, status: nil)

      allocation.unfill
      expect(allocation).to be_unfilled
    end

    it 'updates the status from nil if it is cancelled' do
      allocation = create(:allocation, status: nil)

      allocation.cancel
      expect(allocation).to be_cancelled
    end
  end
end
