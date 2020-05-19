# frozen_string_literal: true

module Idempotence
  class ConflictError < StandardError
    def initialize(key)
      super("conflicting idempotency key: #{key}")
    end
  end
end
