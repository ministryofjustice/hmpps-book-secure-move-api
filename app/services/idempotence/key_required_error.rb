# frozen_string_literal: true

module Idempotence
  class KeyRequiredError < ArgumentError
    def initialize
      super('idempotency key is required')
    end
  end
end
