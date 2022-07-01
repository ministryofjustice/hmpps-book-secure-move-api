# frozen_string_literal: true

desc "Sends create_move notifications for Moves that don't have them"
task notify_unnotified_moves: :environment do
  NotifyUnnotifiedMovesWorker.perform_async

  puts 'The NotifyUnnotifiedMovesWorker has been queued.'
end
