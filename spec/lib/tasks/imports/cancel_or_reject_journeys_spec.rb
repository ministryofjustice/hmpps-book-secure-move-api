# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rake::Task['import:cancel_or_reject_journeys:serco'] do
  let(:results) { instance_double('Imports::Results') }

  before do
    allow(results).to receive(:summary).and_return('Summary')
    allow(Imports::CancelOrRejectJourneys).to receive(:call).and_return(results)
    described_class.reenable
  end

  it 'calls the importer with the right parameters' do
    expect(Imports::CancelOrRejectJourneys).to receive(:call).with(
      csv_path: 'data.csv',
      columns: {
        journey_id: :id,
        move_id: :move_id,
        event_timestamp: :timeofendingevent,
      },
    )

    expect { described_class.invoke('data.csv') }
      .to output('Summary').to_stdout
  end
end
