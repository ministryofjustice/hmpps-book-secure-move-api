# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rake::Task['import:moves_without_ending_state:serco'] do
  let(:results) { instance_double('Imports::Results') }

  before do
    allow(results).to receive(:summary).and_return('Summary')
    allow(Imports::MovesWithoutEndingState).to receive(:call).and_return(results)
    described_class.reenable
  end

  it 'calls the importer with the right parameters' do
    expect(Imports::MovesWithoutEndingState).to receive(:call).with(
      csv_path: 'data.csv',
      columns: {
        move_id: :BASMMOJMoveID,
        old_status: :BASMMoveStatus,
        new_status: :SERs_journeyStatus,
      },
    )

    expect { described_class.invoke('data.csv') }
      .to output('Summary').to_stdout
  end
end
