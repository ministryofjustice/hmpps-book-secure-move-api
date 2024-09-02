# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::MissingMoveEndingEvents do
  let(:completed_move) { create(:move, :in_transit) }
  let(:cancelled_move) { create(:move, :booked) }
  let(:rejected_move) { create(:move, :requested) }

  let(:csv) do
    "move_id,event_type,event_timestamp,cancellation_reason,rejection_reason\nabc,abc,abc,,\nabc,MoveComplete,abc,,\n#{completed_move.id},MoveComplete,2020-01-01,,\n#{cancelled_move.id},MoveCancel,2020-01-01,made_in_error,\n#{rejected_move.id},MoveReject,2020-01-01,,no_space_at_receiving_prison"
  end

  let(:csv_path) do
    file = Tempfile.new('csv')
    file.write(csv)
    file.close
    file.path
  end

  let(:columns) do
    {
      move_id: :move_id,
      event_type: :event_type,
      event_timestamp: :event_timestamp,
      cancellation_reason: :cancellation_reason,
      rejection_reason: :rejection_reason,
    }
  end

  describe '#call' do
    subject(:results) { described_class.call(csv_path:, columns:) }

    it 'imports all rows' do
      expect(results.total).to eq(5)
    end

    it 'records failures' do
      expect(results.failures).to match_array([
        { move_id: 'abc', event_type: 'MoveComplete', event_timestamp: 'abc', cancellation_reason: nil, rejection_reason: nil, reason: 'Could not find move.' },
        { move_id: 'abc', event_type: 'abc', event_timestamp: 'abc', cancellation_reason: nil, rejection_reason: nil, reason: 'Event type not allowed.' },
      ])
    end

    it 'records successes' do
      expect(results.successes).to match_array([
        { move_id: completed_move.id, event_type: 'MoveComplete', event_timestamp: '2020-01-01', cancellation_reason: nil, rejection_reason: nil },
        { move_id: cancelled_move.id, event_type: 'MoveCancel', event_timestamp: '2020-01-01', cancellation_reason: 'made_in_error', rejection_reason: nil },
        { move_id: rejected_move.id, event_type: 'MoveReject', event_timestamp: '2020-01-01', cancellation_reason: nil, rejection_reason: 'no_space_at_receiving_prison' },
      ])
    end

    describe 'events' do
      before { results } # to execute import

      let(:complete_event) { GenericEvent::MoveComplete.first }
      let(:cancel_event) { GenericEvent::MoveCancel.first }
      let(:reject_event) { GenericEvent::MoveReject.first }

      it 'records the events' do
        expect(complete_event.eventable).to eq(completed_move)
        expect(cancel_event.eventable).to eq(cancelled_move)
        expect(reject_event.eventable).to eq(rejected_move)
      end

      it 'records the timestamp' do
        expect(complete_event.occurred_at).to eq(Date.new(2020, 1, 1))
        expect(cancel_event.occurred_at).to eq(Date.new(2020, 1, 1))
        expect(reject_event.occurred_at).to eq(Date.new(2020, 1, 1))
      end

      it 'records the supplier on the events' do
        expect(complete_event.supplier).to eq(completed_move.supplier)
        expect(cancel_event.supplier).to eq(cancelled_move.supplier)
        expect(reject_event.supplier).to eq(rejected_move.supplier)
      end

      it 'records the cancellation reason' do
        expect(cancel_event.cancellation_reason).to eq('made_in_error')
      end

      it 'records the rejection reason' do
        expect(reject_event.rejection_reason).to eq('no_space_at_receiving_prison')
      end
    end

    describe 'moves' do
      before do
        results # to execute import

        completed_move.reload
        cancelled_move.reload
        rejected_move.reload
      end

      it 'updates the statuses' do
        expect(completed_move.status).to eq('completed')
        expect(completed_move.completed?).to be(true)

        expect(cancelled_move.status).to eq('cancelled')
        expect(cancelled_move.cancelled?).to be(true)

        expect(rejected_move.status).to eq('cancelled')
        expect(rejected_move.cancelled?).to be(true)
      end

      it 'sets the cancellation reasons' do
        expect(completed_move.cancellation_reason).to be_nil
        expect(cancelled_move.cancellation_reason).to eq('made_in_error')
        expect(rejected_move.cancellation_reason).to eq('rejected')
      end

      it 'sets the rejection reasons' do
        expect(completed_move.rejection_reason).to be_nil
        expect(cancelled_move.rejection_reason).to be_nil
        expect(rejected_move.rejection_reason).to eq('no_space_at_receiving_prison')
      end
    end
  end
end
