module CloudData
  class ReportsFeed
    DATABASE_NAME = 'feeds_report'.freeze

    def initialize(bucket_name = ENV['S3_REPORTING_BUCKET_NAME'])
      client = Aws::S3::Client.new(
        access_key_id: ENV['S3_REPORTING_ACCESS_KEY_ID'],
        secret_access_key: ENV['S3_REPORTING_SECRET_ACCESS_KEY'],
      )
      @s3 = Aws::S3::Resource.new(client: client)
      @bucket = @s3.bucket(bucket_name)
    end

    def write(content, table, report_date = Time.zone.yesterday)
      path = full_path(report_date, table)

      obj = bucket.object(path)
      obj.put(acl: 'bucket-owner-full-control', body: content, server_side_encryption: 'AES256')

      path
    end

  private

    attr_reader :bucket

    def full_path(report_date, table)
      "#{ENV.fetch('S3_REPORTING_PROJECT_PATH')}/" \
      'data/' \
      "database_name=#{DATABASE_NAME}/" \
      "table_name=#{table}/" \
      "extraction_timestamp=#{report_date.strftime('%Y%m%d%H%M%SZ')}/" \
      "#{report_date.strftime('%Y-%m-%d')}-#{table}.jsonl"
    end
  end
end
