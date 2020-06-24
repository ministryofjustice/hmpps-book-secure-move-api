# frozen_string_literal: true

require 'redis'

module Idempotency
  class Store
    # NB the caching vs conflict logic is:
    # *  re-using the idempotency key with the same request for 10 mins will return the same cached response
    # *  re-using the idempotency key with the same request after 10 mins to 12 hours will raise a conflict error
    # *  re-using the idempotency key with a different request will raise a conflict error, for 12 hours

    CACHE_RESPONSE_TTL = 600 # 10 minutes
    CONFLICT_TTL = 43_200 # 12 hours

    attr_reader :idempotency_key, :conflict_key, :cache_response_key

    def initialize(request)
      @idempotency_key = request.headers['IDEMPOTENCY_KEY']
      @conflict_key = "conf|#{idempotency_key}"
      @cache_response_key = "resp|#{idempotency_key}|#{request_hash(request)}"
    end

    def get
      # Return the cached response if it matches the idempotency key and request
      cached_response = redis.hgetall(cache_response_key)

      return cached_response if cached_response.present?

      # Otherwise, raise a conflict error of the idempotency key exists, or return nil if not
      conflict = redis.get(conflict_key)
      raise ConflictError, idempotency_key unless conflict.nil?
    end

    def set(response)
      # cache the response for a short time
      redis.hmset(cache_response_key, *response)
      redis.expire cache_response_key, CACHE_RESPONSE_TTL

      # set conflict flag for a longer time
      redis.set(conflict_key, '1', ex: CONFLICT_TTL)
    end

  private

    def redis_url
      @redis_url ||= ENV.fetch('REDIS_URL', nil)
    end

    def redis
      @redis ||= Redis.new(url: redis_url)
    end

    def request_hash(request)
      Digest::MD5.base64digest("#{request.method}|#{request.path}|#{request.raw_post}")
    end
  end
end
