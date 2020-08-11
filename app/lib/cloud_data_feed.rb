class CloudDataFeed
  def initialize(bucket_name = ENV['S3_REPORTING_BUCKET_NAME'])
    s3 = Aws::S3::Resource.new
    @bucket = s3.bucket(bucket_name)
  end

  def write(content, obj_name)
    report_date = Time.zone.today.strftime('%Y/%m/%d')

    obj = @bucket.object("#{report_date}/#{obj_name}")
    obj.put(body: content)
  end
end
