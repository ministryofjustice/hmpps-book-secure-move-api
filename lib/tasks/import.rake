# frozen_string_literal: true

namespace :import do
  namespace :journeys_missing_vehicle do
    desc "Import journeys which are missing a vehicle using Serco's spreadsheets."
    task :serco, [:csv_path] => :environment do |_, args|
      csv_path = args.fetch(:csv_path)
      columns = {
        journey_id: :BASMMOJJourneyID,
        move_id: :BASMMOJMoveID,
        vehicle_registration: :SERs_vehicleReg,
      }

      print Imports::JourneysMissingVehicle.call(csv_path: csv_path, columns: columns).summary
    end
  end
end
