# frozen_string_literal: true

namespace :import do
  namespace :cancel_or_reject_journeys do
    desc "Cancels or rejects journeys using Serco's spreadsheets."
    task :serco, [:csv_path] => :environment do |_, args|
      csv_path = args.fetch(:csv_path)
      columns = {
        journey_id: :id,
        move_id: :move_id,
        event_timestamp: :timeofendingevent,
      }

      print Imports::CancelOrRejectJourneys.call(csv_path:, columns:).summary
    end
  end

  namespace :delete_events do
    desc "Deletes events which are invalid a vehicle using Serco's spreadsheets."
    task :serco, [:csv_path] => :environment do |_, args|
      csv_path = args.fetch(:csv_path)
      columns = {
        event_id: :moveeventid,
        eventable_id: :moveid,
      }

      print Imports::DeleteEvents.call(csv_path:, columns:).summary
    end
  end

  namespace :events_incorrect_occurred_at do
    desc "Import events which have an incorrect occurred at time using Serco's spreadsheets."
    task :serco, [:csv_path] => :environment do |_, args|
      csv_path = args.fetch(:csv_path)
      columns = {
        event_id: :moveeventid,
        eventable_id: :moveid,
        occurred_at: :timetoupdate,
      }

      print Imports::EventsIncorrectOccurredAt.call(csv_path:, columns:).summary
    end
  end

  namespace :journeys_missing_vehicle do
    desc "Import journeys which are missing a vehicle using Serco's spreadsheets."
    task :serco, [:csv_path] => :environment do |_, args|
      csv_path = args.fetch(:csv_path)
      columns = {
        journey_id: :basmmojjourneyid,
        move_id: :basmmojmoveid,
        vehicle_registration: :sers_vehiclereg,
      }

      print Imports::JourneysMissingVehicle.call(csv_path:, columns:).summary
    end
  end

  namespace :journeys_without_ending_state do
    desc "Import journeys which don't have an ending state using Serco's spreadsheets."
    task :serco, [:csv_path] => :environment do |_, args|
      csv_path = args.fetch(:csv_path)
      columns = {
        journey_id: :basm_id,
        move_id: :basm_moveid,
        old_state: :basm_state,
        new_state: :sers_status,
      }

      print Imports::JourneysWithoutEndingState.call(csv_path:, columns:).summary
    end
  end

  namespace :missing_journey_ending_events do
    desc "Import events for journeys which are missing an ending event using Serco's spreadsheets."
    task :serco, [:csv_path] => :environment do |_, args|
      csv_path = args.fetch(:csv_path)
      columns = {
        journey_id: :basm_id,
        move_id: :basm_moveid,
        new_state: :sers_status,
        event_timestamp: :basm_client_timestamp,
      }

      print Imports::MissingJourneyEndingEvents.call(csv_path:, columns:).summary
    end
  end

  namespace :missing_journey_start_events do
    desc "Import events for journeys which are missing a start event using Serco's spreadsheets."
    task :serco, [:csv_path] => :environment do |_, args|
      csv_path = args.fetch(:csv_path)
      columns = {
        journey_id: :journeyid,
        event_timestamp: :timeofjourneystartevent,
      }

      print Imports::MissingJourneyStartEvents.call(csv_path:, columns:).summary
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

      print Imports::MissingMoveEndingEvents.call(csv_path:, columns:).summary
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

      print Imports::MissingMoveStartEvents.call(csv_path:, columns:).summary
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

      print Imports::MovesWithoutEndingState.call(csv_path:, columns:).summary
    end
  end

  namespace :moves_without_to_location do
    desc "Import moves which don't have a to location using Serco's spreadsheets."
    task :serco, [:csv_path] => :environment do |_, args|
      csv_path = args.fetch(:csv_path)
      columns = {
        move_id: :id,
        location_key: :mojdestlocationcode,
      }

      print Imports::MovesWithoutToLocation.call(csv_path:, columns:).summary
    end
  end
end
