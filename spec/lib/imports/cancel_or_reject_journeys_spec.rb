# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::CancelOrRejectJourneys do
  let(:completed_journey) { create(:journey, :completed) }
  let(:cancelled_journey) { create(:journey, :cancelled) }
  let(:rejected_journey) { create(:journey, :rejected) }
  let(:in_progress_journey) { create(:journey, :in_progress) }
  let(:proposed_journey) { create(:journey, :proposed) }

  let(:csv) do
    [
      'journey_id,move_id,event_timestamp',
      'abc,abc,2020-01-01',
      "#{completed_journey.id},#{completed_journey.move_id},2020-01-01",
      "#{cancelled_journey.id},#{cancelled_journey.move_id},2020-01-01",
      "#{rejected_journey.id},#{rejected_journey.move_id},2020-01-01",
      "#{in_progress_journey.id},#{in_progress_journey.move_id},2020-01-01",
      "#{proposed_journey.id},#{proposed_journey.move_id},2020-01-01",
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
      event_timestamp: :event_timestamp,
    }
  end

  describe '#call' do
    subject(:results) { described_class.call(csv_path: csv_path, columns: columns) }

    it 'imports all rows' do
      expect(results.total).to eq(6)
    end

    it 'records failures' do
      expect(results.failures).to match_array([
        { journey_id: 'abc', move_id: 'abc', event_timestamp: '2020-01-01', reason: 'Could not find journey.' },
      ])
    end

    it 'records successes' do
      expect(results.successes).to match_array([
        { journey_id: completed_journey.id, move_id: completed_journey.move_id, event_timestamp: '2020-01-01' },
        { journey_id: cancelled_journey.id, move_id: cancelled_journey.move_id, event_timestamp: '2020-01-01' },
        { journey_id: rejected_journey.id, move_id: rejected_journey.move_id, event_timestamp: '2020-01-01' },
        { journey_id: in_progress_journey.id, move_id: in_progress_journey.move_id, event_timestamp: '2020-01-01' },
        { journey_id: proposed_journey.id, move_id: proposed_journey.move_id, event_timestamp: '2020-01-01' },
      ])
    end

    describe 'events' do
      before { results } # to execute import

      it 'uncompletes and cancels completed journeys' do
        expect(completed_journey.generic_events.map(&:class)).to match_array([
          GenericEvent::JourneyUncomplete,
          GenericEvent::JourneyCancel,
        ])
      end

      it 'leaves cancelled journeys' do
        expect(cancelled_journey.generic_events).to be_empty
      end

      it 'leaves rejected journeys' do
        expect(rejected_journey.generic_events).to be_empty
      end

      it 'cancels in progress journeys' do
        expect(in_progress_journey.generic_events.map(&:class)).to match_array([
          GenericEvent::JourneyCancel,
        ])
      end

      it 'rejects proposed journeys' do
        expect(proposed_journey.generic_events.map(&:class)).to match_array([
          GenericEvent::JourneyReject,
        ])
      end
    end

    it 'updates the journey statuses' do
      results # to execute import

      expect(completed_journey.reload.cancelled?).to be(true)
      expect(cancelled_journey.reload.cancelled?).to be(true)
      expect(rejected_journey.reload.rejected?).to be(true)
      expect(in_progress_journey.reload.cancelled?).to be(true)
      expect(proposed_journey.reload.rejected?).to be(true)
    end
  end
end
