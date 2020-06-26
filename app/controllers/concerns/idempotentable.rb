module Idempotentable
  extend ActiveSupport::Concern

  included do
    before_action :validate_idempotency_key
    around_action :idempotent_action
  end

private

  def idempotent_action
    Idempotency::Store.new(idempotency_key, idempotent_request_hash).tap do |stored_response|
      cached_response = stored_response.get

      if cached_response.present?
        render status: cached_response['status'], body: cached_response['body'], content_type: cached_response['content_type']
      else
        yield
        stored_response.set(status: response.status, body: response.body, content_type: response.content_type)
      end
    end
  end

  def validate_idempotency_key
    Idempotency::KeyValidator.new(idempotency_key).validate!
  end

  def idempotent_request_hash
    Digest::MD5.base64digest("#{request.method}|#{request.path}|#{request.raw_post}")
  end

  def idempotency_key
    request.headers['Idempotency-Key'] # NB because of rails magic this is not case sensitive and includes IDEMPOTENCY_KEY
  end
end
