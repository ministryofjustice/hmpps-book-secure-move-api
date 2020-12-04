namespace :metrics do
  desc 'Exports metrics in all the popular formats to s3'
  task export: :environment do
    abort 'Please set the env-var S3_METRICS_BUCKET_NAME' if ENV['S3_METRICS_BUCKET_NAME'].blank?

    # get list of all available metrics
    METRIC_CLASSES = [Metrics::Moves].map { |namespace|
      namespace.constants.map { |c| namespace.const_get(c) if namespace.const_get(c).is_a? Class }.compact
    }.flatten

    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(ENV['S3_METRICS_BUCKET_NAME'])

    METRIC_CLASSES.each do |metric_class|
      metric_class.new.tap do |metric|
        puts metric.label
        metric_class::FORMATS.each do |format_key, format_file|
          bucket.object("#{metric.file}/#{format_file}").tap do |obj|
            if !obj.exists? || obj.last_modified + metric.interval < Time.zone.now
              obj.put(body: metric.send(format_key))
            end
          end
        end

        # sleep for a short while to avoid overloading the system
        sleep(rand(0..0.5).round(2))
      end
    end
  end
end
