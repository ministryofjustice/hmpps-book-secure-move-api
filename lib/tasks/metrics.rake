namespace :metrics do
  desc 'Exports metrics in all the popular formats to s3'
  task export: :environment do
    abort 'Please set S3_METRICS_ACCESS_KEY_ID' if ENV['S3_METRICS_ACCESS_KEY_ID'].blank?
    abort 'Please set S3_METRICS_SECRET_ACCESS_KEY' if ENV['S3_METRICS_SECRET_ACCESS_KEY'].blank?
    abort 'Please set S3_METRICS_REGION' if ENV['S3_METRICS_REGION'].blank?
    abort 'Please set S3_METRICS_BUCKET_NAME' if ENV['S3_METRICS_BUCKET_NAME'].blank?

    # get list of all available metrics
    METRIC_CLASSES = [Metrics::Moves].map { |namespace|
      namespace.constants.map { |c| namespace.const_get(c) if namespace.const_get(c).is_a? Class }.compact
    }.flatten

    feed = CloudData::MetricsFeed.new(ENV['S3_METRICS_BUCKET_NAME'])

    METRIC_CLASSES.each do |metric_class|
      metric_class.new.tap do |metric|
        puts metric.label
        metric_class::FORMATS.each do |format_key, format_file|
          key = "#{metric.file}/#{format_file}"
          expired_before = Time.zone.now - (metric.interval || 0)

          if feed.stale?(key, expired_before)
            feed.update(key, metric.send(format_key))
          end
        end

        # sleep for a short while to avoid overloading the system
        sleep(rand(0..0.5).round(2))
      end
    end
  end
end
