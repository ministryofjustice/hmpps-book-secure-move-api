# frozen_string_literal: true

module Idempotency
  class HeadersValidator
    include ActiveModel::Validations

    attr_reader :idempotency_key

    validates :idempotency_key, presence: true
    # a relatively relaxed regex to allow for any uuid version
    validates_format_of :idempotency_key, with: /\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\Z/i

    def initialize(headers)
      # NB: we need to do a case-insensitive match for IDEMPOTENCY_KEY; rails does not do this automatically if the key contains an underscore
      @idempotency_key = headers.find{ |key, _v| key =~ /\AIDEMPOTENCY[\_\-]KEY\Z/i }&.last
    end
  end
end
