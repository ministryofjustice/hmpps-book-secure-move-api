# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::MovesWithoutToLocation do
  let(:move) { create(:move, :prison_recall) }
  let(:location) { create(:location) }

  let(:csv) do
    [
      'move_id,location_key',
      'abc,abc',
      "#{move.id},abc",
      "#{move.id},#{location.key}",
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
      location_key: :location_key,
    }
  end

  describe '#call' do
    subject(:results) { described_class.call(csv_path: csv_path, columns: columns) }

    it 'imports all rows' do
      expect(results.total).to eq(3)
    end

    it 'records failures' do
      expect(results.failures).to match_array([
        { move_id: 'abc', location_key: 'abc', reason: 'Could not find move.' },
        { move_id: move.id, location_key: 'abc', reason: 'Could not find location.' },
      ])
    end

    it 'records successes' do
      expect(results.successes).to match_array([
        { move_id: move.id, location_key: location.key },
      ])
    end

    it 'sets new status on successful moves' do
      results # to execute import

      expect(move.reload.to_location).to eq(location)
    end
  end
end
