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
end
