# frozen_string_literal: true

desc 'Find notifications with no delivery attempts and recreate the job'
task requeue_unsent_notifications: :environment do
  RequeueUnsentNotificationsWorker.perform_async

  puts 'The RequeueUnsentNotificationsWorker has been queued.'
end
