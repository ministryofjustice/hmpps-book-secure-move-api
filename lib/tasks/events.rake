# frozen_string_literal: true

namespace :events do
  desc 'copy uncopied events to generic_event table'
  task copy: :environment do
    dry_run = ENV.fetch('DRY_RUN', 'true') == 'true'

    EventCopier.new.call
  end

  desc 'rollback copied events'
  task rollback: :environment do
    dry_run = ENV.fetch('DRY_RUN', 'true') == 'true'

    GenericEvent.where(id: Event.copied.pluck(:generic_event_id)).delete_all
  end

  desc 'report on copied events'
  task report: :environment do
    dry_run = ENV.fetch('DRY_RUN', 'true') == 'true'
  end
end
