namespace :metrics do
  desc 'Exports metrics in all the popular formats to s3'
  task :export, [:metric_class] => :environment do |_, args|
    abort 'Please set S3_METRICS_REGION' if ENV['S3_METRICS_REGION'].blank?
    abort 'Please set S3_METRICS_BUCKET_NAME' if ENV['S3_METRICS_BUCKET_NAME'].blank?

    # get list of all available metrics
    metric_classes = [Metrics::Moves, Metrics::PersonEscortRecords].map { |namespace|
      namespace.constants.map { |c| namespace.const_get(c) if namespace.const_get(c).is_a? Class }.compact
    }.flatten

    suppliers = Supplier.all.to_a << nil # NB: the nil supplier means "any supplier"

    feed = CloudData::MetricsFeed.new(ENV['S3_METRICS_BUCKET_NAME'])

    metric_classes.each do |metric_class|
      if args[:metric_class].present? && metric_class.to_s != args[:metric_class]
        next # skip metric
      end

      suppliers.each do |supplier|
        metric_class.new(supplier:).tap do |metric|
          metric_class::FORMATS.each do |format_key, format_file|
            key = "#{metric.database}/#{metric.file}/#{format_file}"
            expired_before = Time.zone.now - (metric.interval || 0)

            print key
            if feed.stale?(key, expired_before)
              feed.update(key, metric.send(format_key))
              puts ' updated'
            else
              puts ' skipped'
            end
          end

          # sleep for a short while to avoid overloading non-test systems
          sleep(rand(0..0.5).round(2)) unless Rails.env.test?
        end
      end
    end
  end
end
