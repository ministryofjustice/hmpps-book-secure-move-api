# frozen_string_literal: true

namespace :events do
  desc 'copy uncopied events to generic_event table'
  task copy: :environment do
    dry_run = ENV.fetch('DRY_RUN', 'true') == 'true'

    report = JSON.parse(EventCopier.new(dry_run: dry_run).call.to_json)

    puts JSON.pretty_generate(report)
  end

  desc 'rollback copied events'
  task rollback: :environment do
    generic_event_ids = Event.copied.pluck(:generic_event_id)

    Event.copied.update_all(generic_event_id: nil)

    puts "Deleting #{generic_event_ids.count} generic_events..."
    GenericEvent.where(id: generic_event_ids).delete_all
end

  desc 'tweak supplier to be based on doorkeeper token rather than the move supplier for initial state events'
  task tweak_supplier: :environment do
    dry_run = ENV.fetch('DRY_RUN', 'true') == 'true'

    puts "DRY_RUN: #{dry_run}"
    puts

    events = GenericEvent.joins(
      # Handle polymorphic event model join
      'INNER JOIN moves ON moves.id = generic_events.eventable_id'
    ).load.where(type: ['GenericEvent::MoveProposed', 'GenericEvent::MoveRequested'])

    report = {
      total_events: events.length,
      events_changed: 0,
      events_unchanged: 0,
      move_proposed_events: 0,
      move_requested_events: 0,
    }

    events.find_each do |event|
      # PaperTrail::Version model rows have an event column which is always one of "create" or "update" (only ever one create)
      initial_version =  event.eventable.versions.find_by(event: "create")

      supplier_different = initial_version.supplier_id != event.supplier_id

      if event.type == 'GenericEvent::MoveProposed'
        report[:move_proposed_events] += 1
      end

      if event.type == 'GenericEvent::MoveRequested'
        report[:move_requested_events] += 1
      end

      if supplier_different
        report[:events_changed] += 1
      else
        report[:events_unchanged] += 1 
      end

      if supplier_different
        event.update(supplier_id: initial_version&.supplier_id) unless dry_run
      end
    end

    puts JSON.pretty_generate(report)
  end
end
