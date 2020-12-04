# frozen_string_literal: true

namespace :events do
  INITIAL_STATE_EVENTS = %w[GenericEvent::MoveProposed GenericEvent::MoveRequested].freeze
  INITIAL_STATUSES = %[proposed requested]

  desc 'Backfills MoveProposed and MoveRequested events since start of time'
  task add_missing_initial_state_events: :environment do
    dry_run = ENV.fetch('DRY_RUN', 'true') == 'true'

    puts "DRY_RUN: #{dry_run}"
    puts

    report = {
      moves_with_initial_state_events: 0,
      moves_without_initial_state_events: 0,
      moves_with_invalid_initial_state: 0,
      proposed_events_to_be_created: 0,
      requested_events_to_be_created: 0,
      events_created: 0,
    }
    GenericEvent.record_timestamps = false
    GenericEvent.no_touching do
      Move.all.find_each do |move|
        if move.generic_events.where(type: INITIAL_STATE_EVENTS).any?
          report[:moves_with_initial_state_events] += 1
        else
          report[:moves_without_initial_state_events] += 1

          # The first time PaperTrail stores the initial version of the whole object isn't on a `create` event
          # The first time PaperTrail stores the initial version is on the first update event
          # And if there have been no updates then the initial version is the current version of the Move stored in the database moves table
          initial_move = move.versions.find_by(event: 'update')&.reify
          initial_move = move unless initial_move.present?

          # We take the create event supplier_id to reflect the user that initially created the first move
          initial_version = move.versions.find_by(event: 'create')
          # Due to a large versions table, we never successfully populated the supplier_id for every version.
          # Handle this by falling back to thei whodunnit field
          initial_supplier = initial_version.supplier_id || initial_version.whodunnit

          unless INITIAL_STATUSES.include?(initial_move.status)
            report[:moves_with_invalid_initial_state] += 1

            next
          end

          event_attributes = {
            eventable: initial_move,
            created_at: initial_move.created_at,
            updated_at: initial_move.created_at,
            occurred_at: initial_move.created_at,
            recorded_at: initial_move.created_at,
            notes: 'Automatically generated event',
            details: {},
            supplier_id: initial_supplier
          }

          if initial_move.proposed?
            report[:proposed_events_to_be_created] += 1

            unless dry_run
              GenericEvent::MoveProposed.create!(event_attributes)

              report[:events_created] += 1
            end
          end

          if initial_move.requested?
            report[:requested_events_to_be_created] += 1

            unless dry_run
              GenericEvent::MoveRequested.create!(event_attributes) 

              report[:events_created] += 1
            end
          end
        end
      end
    end
    GenericEvent.record_timestamps = true

    puts JSON.pretty_generate(report)
  end
end
