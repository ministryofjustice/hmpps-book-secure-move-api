# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::DeleteEvents do
  let(:event) { create(:event_move_proposed) }

  let(:csv) do
    [
      'event_id,eventable_id',
      'abc,abc',
      "#{event.id},abc",
      "#{event.id},#{event.eventable_id}",
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
    }
  end

  describe '#call' do
    subject(:results) { described_class.call(csv_path:, columns:) }

    it 'imports all rows' do
      expect(results.total).to eq(3)
    end

    it 'records failures' do
      expect(results.failures).to match_array([
        { event_id: event.id, eventable_id: 'abc', reason: 'Could not find event.' },
        { event_id: 'abc', eventable_id: 'abc', reason: 'Could not find event.' },
      ])
    end

    it 'records successes' do
      expect(results.successes).to match_array([
        { event_id: event.id, eventable_id: event.eventable_id },
      ])
    end

    it 'deletes the events' do
      results # to execute import

      expect { event.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
