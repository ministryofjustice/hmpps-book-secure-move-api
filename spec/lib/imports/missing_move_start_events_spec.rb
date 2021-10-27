# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::MissingMoveStartEvents do
  let(:move) { create(:move, :in_transit) }

  let(:csv) do
    "move_id,event_timestamp\nabc,abc\n#{move.id},2020-01-01"
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
        { move_id: 'abc', event_timestamp: 'abc' },
      ])
    end

    it 'records successes' do
      expect(results.successes).to match_array([
        { move_id: move.id, event_timestamp: '2020-01-01' },
      ])
    end

    describe 'events' do
      subject(:start_event) { GenericEvent::MoveStart.first }

      before { results } # to execute import

      it 'records the events' do
        expect(start_event.eventable).to eq(move)
      end

      it 'records the timestamp' do
        expect(start_event.occurred_at).to eq(Date.new(2020, 1, 1))
      end

      it 'records the supplier on the events' do
        expect(start_event.supplier).to eq(move.supplier)
      end
    end

    describe 'moves' do
      before do
        results # to execute import
        move.reload
      end

      it "doesn't update the statuses" do
        expect(move.status).to eq('in_transit')
        expect(move.in_transit?).to be(true)
      end
    end
  end
end
