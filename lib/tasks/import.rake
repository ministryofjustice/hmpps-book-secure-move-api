# frozen_string_literal: true

namespace :import do
  namespace :journeys_missing_vehicle do
    desc "Import journeys which are missing a vehicle using Serco's spreadsheets."
    task :serco, [:csv_path] => :environment do |_, args|
      csv_path = args.fetch(:csv_path)
      columns = {
        journey_id: :basmmojjourneyid,
        move_id: :basmmojmoveid,
        vehicle_registration: :sers_vehiclereg,
      }

      print Imports::JourneysMissingVehicle.call(csv_path: csv_path, columns: columns).summary
    end
  end

  namespace :missing_move_ending_events do
    desc "Import events for moves which are missing an ending event using Serco's spreadsheets."
    task :serco, [:csv_path] => :environment do |_, args|
      csv_path = args.fetch(:csv_path)
      columns = {
        move_id: :basmmojmoveid,
        event_type: :sersendingevent,
        event_timestamp: :timeofendingevent,
        cancellation_reason: :cancellationreason,
        rejection_reason: :cancellationreason,
      }

      print Imports::MissingMoveEndingEvents.call(csv_path: csv_path, columns: columns).summary
    end
  end

  namespace :missing_move_start_events do
    desc "Import events for moves which are missing a start event using Serco's spreadsheets."
    task :serco, [:csv_path] => :environment do |_, args|
      csv_path = args.fetch(:csv_path)
      columns = {
        move_id: :basmmojmoveid,
        event_timestamp: :timeofmovestartevent,
      }

      print Imports::MissingMoveStartEvents.call(csv_path: csv_path, columns: columns).summary
    end
  end

  namespace :moves_without_ending_state do
    desc "Import moves which don't have an ending state using Serco's spreadsheets."
    task :serco, [:csv_path] => :environment do |_, args|
      csv_path = args.fetch(:csv_path)
      columns = {
        move_id: :basmmojmoveid,
        old_status: :basmmovestatus,
        new_status: :sersstatus,
      }

      print Imports::MovesWithoutEndingState.call(csv_path: csv_path, columns: columns).summary
    end
  end
end
