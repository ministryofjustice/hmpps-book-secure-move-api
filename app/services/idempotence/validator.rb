# frozen_string_literal: true

require 'redis'

module Idempotence
  class Validator
    TTL = 43200 # 12 hours in seconds

    def call(key, required: true)
      raise KeyRequiredError if required && key.blank?

      return nil if key.blank? || redis_url.blank?

      if redis.get(key)
        # the key was found: so this is an error
        raise ConflictError.new(key)
      else
        redis.set(key, 'T', ex: TTL) == 'OK'
      end
    end

  private

    def redis_url
      @redis_url ||= ENV.fetch('REDIS_URL', nil)
    end

    def redis
      @redis ||= Redis.new(url: redis_url)
    end
  end
end
