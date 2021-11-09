# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rake::Task['import:missing_journey_ending_events:serco'] do
  let(:results) { instance_double('Imports::Results') }

  before do
    allow(results).to receive(:summary).and_return('Summary')
    allow(Imports::MissingJourneyEndingEvents).to receive(:call).and_return(results)
    described_class.reenable
  end

  it 'calls the importer with the right parameters' do
    expect(Imports::MissingJourneyEndingEvents).to receive(:call).with(
      csv_path: 'data.csv',
      columns: {
        journey_id: :basm_id,
        move_id: :basm_moveid,
        new_state: :sers_status,
        event_timestamp: :basm_client_timestamp,
      },
    )

    expect { described_class.invoke('data.csv') }
      .to output('Summary').to_stdout
  end
end
