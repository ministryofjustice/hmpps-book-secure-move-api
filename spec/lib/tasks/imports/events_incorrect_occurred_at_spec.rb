# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rake::Task['import:events_incorrect_occurred_at:serco'] do
  let(:results) { instance_double(Imports::Results) }

  before do
    allow(results).to receive(:summary).and_return('Summary')
    allow(Imports::EventsIncorrectOccurredAt).to receive(:call).and_return(results)
    described_class.reenable
  end

  it 'calls the importer with the right parameters' do
    expect(Imports::EventsIncorrectOccurredAt).to receive(:call).with(
      csv_path: 'data.csv',
      columns: {
        event_id: :moveeventid,
        eventable_id: :moveid,
        occurred_at: :timetoupdate,
      },
    )

    expect { described_class.invoke('data.csv') }
      .to output('Summary').to_stdout
  end
end
