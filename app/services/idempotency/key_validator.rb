# frozen_string_literal: true

module Idempotency
  class KeyValidator
    include ActiveModel::Validations

    attr_reader :idempotency_key

    validates :idempotency_key, presence: true
    # a relatively relaxed regex to allow for any uuid version
    validates_format_of :idempotency_key, with: /\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\Z/i

    def initialize(idempotency_key)
      @idempotency_key = idempotency_key
    end
  end
end
