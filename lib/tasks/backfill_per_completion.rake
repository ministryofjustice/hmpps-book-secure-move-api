# frozen_string_literal: true

namespace :backfill do
  desc 'Backfill PerCompletion events'
  task per_completion: :environment do
    PersonEscortRecord.where.not(completed_at: nil).find_in_batches.each do |batch|
      batch.each do |per|
        next if per.generic_events.where(type: 'GenericEvent::PerCompletion').present?

        per.generic_events << GenericEvent::PerCompletion.new(
          occurred_at: per.completed_at,
          recorded_at: per.completed_at,
          details: { completed_at: per.completed_at },
        )

        per.save!
      end
    end
  end
end
