# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::EventsIncorrectOccurredAt do
  let(:event) { create(:event_move_proposed) }

  let(:csv) do
    [
      'event_id,eventable_id,occurred_at',
      'abc,abc,2020-01-01T00:00:00Z',
      "#{event.id},abc,2020-01-01T00:00:00Z",
      "#{event.id},#{event.eventable_id},2020-01-01T00:00:00Z",
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
      event_id: :event_id,
      eventable_id: :eventable_id,
      occurred_at: :occurred_at,
    }
  end

  describe '#call' do
    subject(:results) { described_class.call(csv_path: csv_path, columns: columns) }

    it 'imports all rows' do
      expect(results.total).to eq(3)
    end

    it 'records failures' do
      expect(results.failures).to match_array([
        { event_id: event.id, eventable_id: 'abc', occurred_at: '2020-01-01T00:00:00Z', reason: 'Could not find event.' },
        { event_id: 'abc', eventable_id: 'abc', occurred_at: '2020-01-01T00:00:00Z', reason: 'Could not find event.' },
      ])
    end

    it 'records successes' do
      expect(results.successes).to match_array([
        { event_id: event.id, eventable_id: event.eventable_id, occurred_at: '2020-01-01T00:00:00Z' },
      ])
    end

    it 'deletes the events' do
      results # to execute import

      expect(event.reload.occurred_at).to eq(Date.new(2020, 1, 1))
    end
  end
end
