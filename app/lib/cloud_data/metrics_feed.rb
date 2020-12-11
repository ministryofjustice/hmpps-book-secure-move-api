module CloudData
  class MetricsFeed
    attr_reader :bucket

    def initialize(bucket, client = Aws::S3::Client.new)
      @client = client
      @bucket = bucket
    end

    def stale?(key, expired_before = nil)
      # An object is stale if:
      # * it doesn't exist, or
      # * expired_before == nil, or
      # * the object was last modified before expired_before
      expired_before.nil? || @client.head_object(bucket: bucket, key: key).last_modified < expired_before
    rescue Aws::S3::Errors::NotFound
      true
    end

    def update(key, body)
      @client.put_object(bucket: bucket, key: key, body: body)
    end
  end
end
