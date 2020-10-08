namespace :metrics do
  desc 'Exports metrics in all the popular formats to s3'
  task export: :environment do
    
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(ENV[S3_METRICS_BUCKET_NAME])

    # get list of all available metrics
    metrics_classes = Metrics.constants.map {|c| Metrics.const_get(c) if Metrics.const_get(c).is_a? Class}.compact

    metrics_classes.each do |metric|
      interval = metric::METRIC[:interval]
      file = metric::METRIC[:file]


      puts metric.inspect
    end


  end
end
