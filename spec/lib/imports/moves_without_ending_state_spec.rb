# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::MovesWithoutEndingState do
  let(:move) { create(:move) }

  let(:csv) do
    "move_id,old_status,new_status\n#{move.id},#{move.status},Completed\n#{move.id},rejected,Completed\nabc,abc,abc"
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

  describe '#call' do
    subject(:results) { described_class.call(csv_path: csv_path, columns: columns) }

    it 'imports all rows' do
      expect(results.total).to eq(3)
    end

    it 'records failures' do
      expect(results.failures).to match_array([
        { move_id: move.id, old_status: 'rejected', new_status: 'Completed' },
        { move_id: 'abc', old_status: 'abc', new_status: 'abc' },
      ])
    end

    it 'records successes' do
      expect(results.successes).to match_array([
        { move_id: move.id, old_status: move.status, new_status: 'Completed' },
      ])
    end

    it 'sets new status on move' do
      results # to execute import
      expect(move.reload.status).to eq('completed')
      expect(move.completed?).to be(true)
    end
  end
end
