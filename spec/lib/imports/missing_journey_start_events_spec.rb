# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::MissingJourneyStartEvents do
  let(:journey) { create(:journey, :in_progress) }

  let(:csv) do
    "journey_id,event_timestamp\nabc,abc\n#{journey.id},2020-01-01"
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
      event_timestamp: :event_timestamp,
    }
  end

  describe '#call' do
    subject(:results) { described_class.call(csv_path: csv_path, columns: columns) }

    it 'imports all rows' do
      expect(results.total).to eq(2)
    end

    it 'records failures' do
      expect(results.failures).to match_array([
        { journey_id: 'abc', event_timestamp: 'abc', reason: 'Could not find journey.' },
      ])
    end

    it 'records successes' do
      expect(results.successes).to match_array([
        { journey_id: journey.id, event_timestamp: '2020-01-01' },
      ])
    end

    describe 'events' do
      subject(:start_event) { GenericEvent::JourneyStart.first }

      before { results } # to execute import

      it 'records the events' do
        expect(start_event.eventable).to eq(journey)
      end

      it 'records the timestamp' do
        expect(start_event.occurred_at).to eq(Date.new(2020, 1, 1))
      end

      it 'records the supplier on the events' do
        expect(start_event.supplier).to eq(journey.supplier)
      end
    end

    describe 'journeys' do
      before do
        results # to execute import
        journey.reload
      end

      it "doesn't update the statuses" do
        expect(journey.state).to eq('in_progress')
        expect(journey.in_progress?).to be(true)
      end
    end
  end
end
