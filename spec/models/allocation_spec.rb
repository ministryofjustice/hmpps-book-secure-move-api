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
  it { is_expected.to allow_value(nil).for(:estate) }
  it { is_expected.to define_enum_for(:estate).backed_by_column_of_type(:string) }

  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_inclusion_of(:status).in_array(%w[unfilled filled cancelled]) }

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
      let(:booked_move) { create :move, :booked }
      let(:in_transit_move) { create :move, :in_transit }
      let(:completed_move) { create :move, :completed }
      let(:moves) { [cancelled_move, proposed_move, requested_move, booked_move, in_transit_move, completed_move] }
      let!(:allocation) { create :allocation, moves: moves, moves_count: 1 }

      it 'updates the number of non cancelled moves' do
        expect { allocation.refresh_status_and_moves_count! }.to change(allocation, :moves_count).from(1).to(5)
      end
    end

    context 'when updating status' do
      it 'sets status to `unfilled` if no profiles associated with uncancelled moves' do
        moves = create_list(:move, 2, profile: nil)
        cancelled_move = create(:move, :cancelled)
        allocation = create(:allocation, moves: moves + [cancelled_move])

        allocation.refresh_status_and_moves_count!
        expect(allocation).to be_unfilled
      end

      it 'sets status to `unfilled` if not all uncancelled moves are associated to profiles' do
        move_without_profile = create(:move, profile: nil)
        move_with_profile = create(:move)
        cancelled_move = create(:move, :cancelled)

        allocation = create(:allocation, moves: [move_without_profile, move_with_profile, cancelled_move])

        allocation.refresh_status_and_moves_count!
        expect(allocation).to be_unfilled
      end

      it 'sets status to `filled` if all uncancelled moves are associated to profiles' do
        moves = create_list(:move, 2)
        cancelled_move = create(:move, :cancelled)

        allocation = create(:allocation, moves: moves + [cancelled_move])

        allocation.refresh_status_and_moves_count!
        expect(allocation).to be_filled
      end

      it 'sets status to `unfilled` if all moves cancelled' do
        cancelled_move = create(:move, :cancelled)

        allocation = create(:allocation, moves: [cancelled_move])

        allocation.refresh_status_and_moves_count!
        expect(allocation).to be_unfilled
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

  describe '#cancel' do
    let(:allocation) { create(:allocation, :with_moves) }

    it 'changes the status of an allocation to cancelled' do
      allocation.cancel

      expect(allocation.status).to eq(described_class::ALLOCATION_STATUS_CANCELLED)
    end

    it 'changes the moves_count of allocation to 0' do
      allocation.cancel

      expect(allocation.moves_count).to eq(0)
    end

    it 'sets the provided cancellation reason' do
      allocation.cancel(reason: described_class::CANCELLATION_REASON_MADE_IN_ERROR)

      expect(allocation.cancellation_reason).to eq(described_class::CANCELLATION_REASON_MADE_IN_ERROR)
    end

    it 'sets a default cancellation reason if reason not provided' do
      allocation.cancel

      expect(allocation.cancellation_reason).to eq(described_class::CANCELLATION_REASON_OTHER)
    end

    it 'sets the cancellation reason comment if provided' do
      allocation.cancel(comment: 'Too sunny')

      expect(allocation.cancellation_reason_comment).to eq('Too sunny')
    end

    it 'sets a default cancellation reason comment if not provided' do
      allocation.cancel

      expect(allocation.cancellation_reason_comment).to eq('Allocation was cancelled')
    end

    it 'throws validation error if allocation invalid' do
      allocation.from_location = nil

      expect { allocation.cancel }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#status' do
    it 'sets the initial status to unfilled' do
      allocation = build(:allocation)

      expect(allocation).to be_unfilled
    end

    it 'restores the current status if it is set' do
      allocation = build(:allocation, :filled)

      expect(allocation).to be_filled
    end
  end

  describe '#fill' do
    it 'updates the status from unfilled' do
      allocation = build(:allocation, :unfilled)

      allocation.fill
      expect(allocation).to be_filled
    end
  end

  describe '#unfill' do
    it 'updates the status from filled' do
      allocation = build(:allocation, :filled)

      allocation.unfill
      expect(allocation).to be_unfilled
    end
  end

  describe '#move_totals' do
    subject(:move_totals) { allocation.move_totals }

    context 'without associated moves' do
      let(:allocation) { create(:allocation) }

      it 'contains zero total and filled move counts' do
        expect(move_totals).to eq({
          total: 0,
          filled: 0,
          unfilled: 0,
        })
      end
    end

    context 'with associated moves' do
      let(:allocation) { create(:allocation, :with_moves, moves_count: 2) }

      before do
        allocation.moves.first.update(profile: nil)
      end

      it 'contains correct total, filled and unfilled move counts' do
        expect(move_totals).to eq({
          total: 2,
          filled: 1,
          unfilled: 1,
        })
      end
    end

    context 'with cancelled moves on a current allocation' do
      let(:allocation) { create(:allocation, :with_moves, moves_count: 3) }

      before do
        allocation.moves.first.update(status: 'cancelled', cancellation_reason: 'other')
        allocation.moves.last.update(profile: nil, status: 'cancelled', cancellation_reason: 'other')
      end

      it 'excludes cancelled moves from all move counts' do
        expect(move_totals).to eq({
          total: 1,
          filled: 1, # Excludes filled cancelled move
          unfilled: 0, # Excludes unfilled cancelled move
        })
      end
    end

    context 'with cancelled moves on a cancelled allocation' do
      let(:allocation) { create(:allocation, :with_moves, :cancelled, moves_count: 2) }

      before do
        allocation.moves.update_all(status: 'cancelled', cancellation_reason: 'other')
      end

      it 'includes cancelled moves in total count' do
        expect(move_totals).to eq({
          total: 2, # Still two moves in total, ignoring status
          filled: 0,
          unfilled: 0,
        })
      end
    end
  end

  describe '.move_totals' do
    subject(:move_totals) { described_class.all.move_totals }

    context 'without associated moves' do
      let!(:allocations) { create_list(:allocation, 2) }

      it 'contains zero total and filled move counts' do
        expect(move_totals).to eq({
          described_class.first.id => {
            total: 0,
            filled: 0,
            unfilled: 0,
          },
          described_class.last.id => {
            total: 0,
            filled: 0,
            unfilled: 0,
          },
        })
      end
    end

    context 'with associated moves' do
      let!(:allocations) { create_list(:allocation, 2, :with_moves, moves_count: 2) }

      before do
        described_class.first.moves.first.update(profile: nil)
      end

      it 'contains correct total, filled and unfilled move counts' do
        expect(move_totals).to eq({
          described_class.first.id => {
            total: 2,
            filled: 1,
            unfilled: 1,
          },
          described_class.last.id => {
            total: 2,
            filled: 2,
            unfilled: 0,
          },
        })
      end
    end

    context 'with cancelled moves on a current allocation' do
      let!(:allocations) { create_list(:allocation, 2, :with_moves, moves_count: 2) }

      before do
        described_class.first.moves.first.update(status: 'cancelled', cancellation_reason: 'other')
        described_class.last.moves.first.update(profile: nil, status: 'cancelled', cancellation_reason: 'other')
      end

      it 'excludes cancelled moves from all move counts' do
        expect(move_totals).to eq({
          described_class.first.id => {
            total: 1,
            filled: 1, # Excludes filled cancelled move
            unfilled: 0,
          },
          described_class.last.id => {
            total: 1,
            filled: 1,
            unfilled: 0, # Excludes unfilled cancelled move
          },
        })
      end
    end

    context 'with cancelled moves on a cancelled allocation' do
      let!(:allocation) { create(:allocation, :with_moves, :cancelled, moves_count: 2) }

      before do
        described_class.first.moves.update_all(status: 'cancelled', cancellation_reason: 'other')
      end

      it 'includes cancelled moves in total count' do
        expect(move_totals).to eq({
          described_class.first.id => {
            total: 2, # Still two moves in total, ignoring status
            filled: 0,
            unfilled: 0,
          },
        })
      end
    end
  end
end
