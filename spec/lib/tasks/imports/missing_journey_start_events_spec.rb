# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rake::Task['import:missing_journey_start_events:serco'] do
  let(:results) { instance_double('Imports::Results') }

  before do
    allow(results).to receive(:summary).and_return('Summary')
    allow(Imports::MissingJourneyStartEvents).to receive(:call).and_return(results)
    described_class.reenable
  end

  it 'calls the importer with the right parameters' do
    expect(Imports::MissingJourneyStartEvents).to receive(:call).with(
      csv_path: 'data.csv',
      columns: {
        journey_id: :journeyid,
        event_timestamp: :timeofjourneystartevent,
      },
    )

    expect { described_class.invoke('data.csv') }
      .to output('Summary').to_stdout
  end
end
