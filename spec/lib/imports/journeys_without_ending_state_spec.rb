# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::JourneysWithoutEndingState do
  let(:journey_without_event) { create(:journey) }
  let(:journey_to_be_completed) { create(:journey) }
  let(:journey_to_be_cancelled) { create(:journey) }
  let(:journey_to_be_rejected) { create(:journey) }

  let(:csv) do
    [
      'journey_id,move_id,old_state,new_state',
      'abc,abc,abc,abc',
      "#{journey_without_event.id},#{journey_without_event.move_id},rejected,Completed",
      "#{journey_without_event.id},#{journey_without_event.move_id},#{journey_without_event.state},Completed",
      "#{journey_to_be_completed.id},#{journey_to_be_completed.move_id},#{journey_to_be_completed.state},Completed",
      "#{journey_to_be_cancelled.id},#{journey_to_be_cancelled.move_id},#{journey_to_be_cancelled.state},Cancelled",
      "#{journey_to_be_rejected.id},#{journey_to_be_rejected.move_id},#{journey_to_be_rejected.state},Rejected",
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
      journey_id: :journey_id,
      move_id: :move_id,
      old_state: :old_state,
      new_state: :new_state,
    }
  end

  before do
    create(:event_journey_complete, eventable: journey_to_be_completed)
    create(:event_journey_cancel, eventable: journey_to_be_cancelled)
    create(:event_journey_reject, eventable: journey_to_be_rejected)
  end

  describe '#call' do
    subject(:results) { described_class.call(csv_path:, columns:) }

    it 'imports all rows' do
      expect(results.total).to eq(6)
    end

    it 'records failures' do
      expect(results.failures).to match_array([
        { journey_id: journey_without_event.id, move_id: journey_without_event.move_id, old_state: 'rejected', new_state: 'completed', reason: 'Could not find journey.' },
        { journey_id: 'abc', move_id: 'abc', old_state: 'abc', new_state: 'abc', reason: 'Could not find journey.' },
        { journey_id: journey_without_event.id, move_id: journey_without_event.move_id, old_state: journey_without_event.state, new_state: 'completed', reason: 'Could not find associated event.' },
      ])
    end

    it 'records successes' do
      expect(results.successes).to match_array([
        { journey_id: journey_to_be_completed.id, move_id: journey_to_be_completed.move_id, old_state: journey_to_be_completed.state, new_state: 'completed' },
        { journey_id: journey_to_be_cancelled.id, move_id: journey_to_be_cancelled.move_id, old_state: journey_to_be_cancelled.state, new_state: 'cancelled' },
        { journey_id: journey_to_be_rejected.id, move_id: journey_to_be_rejected.move_id, old_state: journey_to_be_rejected.state, new_state: 'rejected' },
      ])
    end

    it 'sets new state on successful journeys' do
      results # to execute import

      expect(journey_to_be_completed.reload.completed?).to be(true)
      expect(journey_to_be_cancelled.reload.cancelled?).to be(true)
      expect(journey_to_be_rejected.reload.rejected?).to be(true)
    end
  end
end
