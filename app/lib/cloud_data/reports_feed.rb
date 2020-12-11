module CloudData
  class ReportsFeed
    def initialize(bucket_name = ENV['S3_REPORTING_BUCKET_NAME'])
      @s3 = Aws::S3::Resource.new
      @bucket = @s3.bucket(bucket_name)
    end

    def write(content, obj_name, report_date = Time.zone.yesterday)
      folder_name = report_date.strftime('%Y/%m/%d')
      filename = report_date.strftime('%Y-%m-%d')

      full_name = "#{folder_name}/#{filename}-#{obj_name}"
      obj = bucket.object(full_name)
      obj.put(body: content)

      full_name
    end

  private

    attr_reader :bucket
  end
end
