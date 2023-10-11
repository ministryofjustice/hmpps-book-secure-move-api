# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::MovesWithoutEndingState do
  let(:move_without_event) { create(:move) }
  let(:move_to_be_completed) { create(:move) }
  let(:move_to_be_cancelled) { create(:move) }
  let(:move_to_be_rejected) { create(:move) }

  let(:csv) do
    [
      'move_id,old_status,new_status',
      'abc,abc,abc',
      "#{move_without_event.id},rejected,Completed",
      "#{move_without_event.id},#{move_without_event.status},Completed",
      "#{move_to_be_completed.id},#{move_to_be_completed.status},Completed",
      "#{move_to_be_cancelled.id},#{move_to_be_cancelled.status},Cancelled",
      "#{move_to_be_rejected.id},#{move_to_be_rejected.status},Rejected",
    ].join("\n")
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
      old_status: :old_status,
      new_status: :new_status,
    }
  end

  before do
    create(:event_move_complete, eventable: move_to_be_completed)
    create(:event_move_cancel, eventable: move_to_be_cancelled)
    create(:event_move_reject, eventable: move_to_be_rejected)
  end

  describe '#call' do
    subject(:results) { described_class.call(csv_path:, columns:) }

    it 'imports all rows' do
      expect(results.total).to eq(6)
    end

    it 'records failures' do
      expect(results.failures).to match_array([
        { move_id: move_without_event.id, old_status: 'rejected', new_status: 'completed', reason: 'Could not find move.' },
        { move_id: 'abc', old_status: 'abc', new_status: 'abc', reason: 'Could not find move.' },
        { move_id: move_without_event.id, old_status: move_without_event.status, new_status: 'completed', reason: 'Could not find associated event.' },
      ])
    end

    it 'records successes' do
      expect(results.successes).to match_array([
        { move_id: move_to_be_completed.id, old_status: move_to_be_completed.status, new_status: 'completed' },
        { move_id: move_to_be_cancelled.id, old_status: move_to_be_cancelled.status, new_status: 'cancelled' },
        { move_id: move_to_be_rejected.id, old_status: move_to_be_rejected.status, new_status: 'rejected' },
      ])
    end

    it 'sets new status on successful moves' do
      results # to execute import

      expect(move_to_be_completed.reload.completed?).to be(true)
      expect(move_to_be_cancelled.reload.cancelled?).to be(true)
      expect(move_to_be_rejected.reload.rejected?).to be(true)
    end
  end
end
