class CloudDataFeed
  def initialize(bucket_name = ENV['S3_REPORTING_BUCKET_NAME'])
    @s3 = Aws::S3::Resource.new
    @bucket = @s3.bucket(bucket_name)
  end

  def write(content, obj_name)
    report_date = Time.zone.today.strftime('%Y/%m/%d')

    full_name = "#{report_date}/#{obj_name}"
    obj = @bucket.object(full_name)
    obj.put(body: content)

    full_name
  end
end
