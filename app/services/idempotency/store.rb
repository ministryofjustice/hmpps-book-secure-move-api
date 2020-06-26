# frozen_string_literal: true

module Idempotency
  class Store
    # NB the caching vs conflict logic is:
    # *  re-using the idempotency key with the same request for 10 mins will return the same cached response
    # *  re-using the idempotency key with the same request after 10 mins to 12 hours will raise a conflict error
    # *  re-using the idempotency key with a different request will raise a conflict error, for 12 hours
    #
    # NB we are using a Redis-backed cache. Using FileStore, MemoryStore (or NullStore) will not work in production.

    CACHE_RESPONSE_TTL = 10.minutes.to_i
    CONFLICT_TTL = 12.hours.to_i

    attr_reader :idempotency_key, :conflict_key, :cache_response_key

    def initialize(idempotency_key, request_hash)
      @idempotency_key = idempotency_key
      @conflict_key = "conf|#{idempotency_key}"
      @cache_response_key = "resp|#{idempotency_key}|#{request_hash}"
    end

    def read
      return if @idempotency_key.blank?

      # Return the cached response if it matches the idempotency key and request
      cached_response = Rails.cache.read(cache_response_key)
      return cached_response if cached_response.present?

      # Otherwise, raise a conflict error of the idempotency key exists, or return nil if not
      conflict = Rails.cache.read(conflict_key)
      raise ConflictError, idempotency_key unless conflict.nil?
    end

    def write(response)
      return if @idempotency_key.blank?

      # cache the response for a short time
      Rails.cache.write(cache_response_key, response, expiry: CACHE_RESPONSE_TTL)

      # set conflict flag for a longer time
      Rails.cache.write(conflict_key, 1, expiry: CONFLICT_TTL)
    end
  end
end
