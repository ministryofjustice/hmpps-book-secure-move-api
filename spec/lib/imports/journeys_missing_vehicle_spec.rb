# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::JourneysMissingVehicle do
  let(:move) { create(:move) }
  let(:journey) { create(:journey, move: move, vehicle_registration: nil) }

  let(:csv) do
    "move_id,journey_id,vehicle_registration\n#{move.id},#{journey.id},ABC DEF\nabc,#{journey.id},ABC DEF\nabc,abc,ABC DEF"
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
      journey_id: :journey_id,
      vehicle_registration: :vehicle_registration,
    }
  end

  describe '#call' do
    subject(:results) { described_class.call(csv_path: csv_path, columns: columns) }

    it 'imports all rows' do
      expect(results.total).to eq(3)
    end

    it 'records failures' do
      expect(results.failures).to match_array([
        { journey_id: journey.id, move_id: 'abc', vehicle_registration: 'ABC DEF', reason: 'Could not find journey.' },
        { journey_id: 'abc', move_id: 'abc', vehicle_registration: 'ABC DEF', reason: 'Could not find journey.' },
      ])
    end

    it 'records successes' do
      expect(results.successes).to match_array([
        { journey_id: journey.id, move_id: move.id, vehicle_registration: 'ABC DEF' },
      ])
    end

    it 'sets vehicle registration on journey' do
      results # to execute import
      expect(journey.reload.vehicle_registration).to eq('ABC DEF')
    end
  end
end
