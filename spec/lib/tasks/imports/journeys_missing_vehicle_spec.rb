# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rake::Task['import:journeys_missing_vehicle:serco'] do
  let(:results) { instance_double('Imports::Results') }

  before do
    allow(results).to receive(:summary).and_return('Summary')
    allow(Imports::JourneysMissingVehicle).to receive(:call).and_return(results)
    described_class.reenable
  end

  it 'calls the importer with the right parameters' do
    expect(Imports::JourneysMissingVehicle).to receive(:call).with(
      csv_path: 'data.csv',
      columns: {
        journey_id: :basmmojjourneyid,
        move_id: :basmmojmoveid,
        vehicle_registration: :sers_vehiclereg,
      },
    )

    expect { described_class.invoke('data.csv') }
      .to output('Summary').to_stdout
  end
end
