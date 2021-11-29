# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rake::Task['import:moves_without_to_location:serco'] do
  let(:results) { instance_double('Imports::Results') }

  before do
    allow(results).to receive(:summary).and_return('Summary')
    allow(Imports::MovesWithoutToLocation).to receive(:call).and_return(results)
    described_class.reenable
  end

  it 'calls the importer with the right parameters' do
    expect(Imports::MovesWithoutToLocation).to receive(:call).with(
      csv_path: 'data.csv',
      columns: {
        move_id: :id,
        location_key: :mojdestlocationcode,
      },
    )

    expect { described_class.invoke('data.csv') }
      .to output('Summary').to_stdout
  end
end
