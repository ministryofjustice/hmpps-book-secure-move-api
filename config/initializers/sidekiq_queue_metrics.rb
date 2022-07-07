require 'sidekiq_queue_metrics'

Sidekiq.configure_server do |config|
  Sidekiq::QueueMetrics.init(config)
end
