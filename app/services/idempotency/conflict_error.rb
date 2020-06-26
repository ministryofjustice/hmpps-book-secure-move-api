# frozen_string_literal: true

module Idempotency
  class ConflictError < StandardError
    def initialize(key)
      super("Conflicting idempotency key: #{key}")
    end
  end
end
