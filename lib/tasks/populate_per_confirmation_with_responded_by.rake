# frozen_string_literal: true

namespace :per_confirmation do
  desc 'Populate PerConfirmation events with responded_by'
  task populate_responded_by: :environment do
    GenericEvent::PerConfirmation.find_in_batches.each do |batch|
      batch.each do |event|
        next unless event.responded_by.nil?
        next if event.eventable.blank?

        event.responded_by = event.eventable.responded_by(event.created_at)
        event.save!
      end
    end
  end
end
