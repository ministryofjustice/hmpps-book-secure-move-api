GITHUB_FRAMEWORK_URI = 'https://github.com/ministryofjustice/hmpps-book-secure-move-frameworks.git'.freeze
GITHUB_FRAMEWORK_NAME = 'hmpps-book-secure-move-frameworks'.freeze
FRAMEWORK_TEMP_PATH = Rails.root.join('tmp/checkout').freeze

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
