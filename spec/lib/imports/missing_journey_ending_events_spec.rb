# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::MissingJourneyEndingEvents do
  let(:completed_journey) { create(:journey, :in_progress) }
  let(:cancelled_journey) { create(:journey, :in_progress) }
  let(:rejected_journey) { create(:journey, :proposed) }

  let(:csv) do
    [
      'journey_id,move_id,new_state,event_timestamp',
      'abc,abc,Unknown,2020-01-01',
      'abc,abc,Completed,2020-01-01',
      "#{completed_journey.id},#{completed_journey.move_id},Completed,2020-01-01",
      "#{cancelled_journey.id},#{cancelled_journey.move_id},Cancelled,2020-01-01",
      "#{rejected_journey.id},#{rejected_journey.move_id},Rejected,2020-01-01",
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
      new_state: :new_state,
      event_timestamp: :event_timestamp,
    }
  end

  describe '#call' do
    subject(:results) { described_class.call(csv_path:, columns:) }

    it 'imports all rows' do
      expect(results.total).to eq(5)
    end

    it 'records failures' do
      expect(results.failures).to match_array([
        { journey_id: 'abc', move_id: 'abc', new_state: 'Unknown', event_timestamp: '2020-01-01', reason: 'New state not allowed.' },
        { journey_id: 'abc', move_id: 'abc', new_state: 'Completed', event_timestamp: '2020-01-01', reason: 'Could not find journey.' },
      ])
    end

    it 'records successes' do
      expect(results.successes).to match_array([
        { journey_id: completed_journey.id, move_id: completed_journey.move_id, new_state: 'Completed', event_timestamp: '2020-01-01' },
        { journey_id: cancelled_journey.id, move_id: cancelled_journey.move_id, new_state: 'Cancelled', event_timestamp: '2020-01-01' },
        { journey_id: rejected_journey.id, move_id: rejected_journey.move_id, new_state: 'Rejected', event_timestamp: '2020-01-01' },
      ])
    end

    describe 'events' do
      before { results } # to execute import

      let(:complete_event) { GenericEvent::JourneyComplete.first }
      let(:cancel_event) { GenericEvent::JourneyCancel.first }
      let(:reject_event) { GenericEvent::JourneyReject.first }

      it 'records the events' do
        expect(complete_event.eventable).to eq(completed_journey)
        expect(cancel_event.eventable).to eq(cancelled_journey)
        expect(reject_event.eventable).to eq(rejected_journey)
      end

      it 'records the timestamp' do
        expect(complete_event.occurred_at).to eq(Date.new(2020, 1, 1))
        expect(cancel_event.occurred_at).to eq(Date.new(2020, 1, 1))
        expect(reject_event.occurred_at).to eq(Date.new(2020, 1, 1))
      end

      it 'records the supplier on the events' do
        expect(complete_event.supplier).to eq(completed_journey.supplier)
        expect(cancel_event.supplier).to eq(cancelled_journey.supplier)
        expect(reject_event.supplier).to eq(rejected_journey.supplier)
      end
    end

    it 'updates the journey statuses' do
      results # to execute import

      expect(completed_journey.reload.state).to eq('completed')
      expect(completed_journey.completed?).to be(true)

      expect(cancelled_journey.reload.state).to eq('cancelled')
      expect(cancelled_journey.cancelled?).to be(true)

      expect(rejected_journey.reload.state).to eq('rejected')
      expect(rejected_journey.rejected?).to be(true)
    end
  end
end
