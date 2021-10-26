# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rake::Task['import:missing_move_ending_events:serco'] do
  let(:results) { instance_double('Imports::Results') }

  before do
    allow(results).to receive(:summary).and_return('Summary')
    allow(Imports::MissingMoveEndingEvents).to receive(:call).and_return(results)
    described_class.reenable
  end

  it 'calls the importer with the right parameters' do
    expect(Imports::MissingMoveEndingEvents).to receive(:call).with(
      csv_path: 'data.csv',
      columns: {
        move_id: :BASMMOJMoveID,
        event_type: :SERSEndingEvent,
        event_timestamp: :TimeOfEndingEvent,
        cancellation_reason: :CancellationReason,
        rejection_reason: :CancellationReason,
      },
    )

    expect { described_class.invoke('data.csv') }
      .to output('Summary').to_stdout
  end
end
