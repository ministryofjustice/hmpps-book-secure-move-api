# frozen_string_literal: true

module FrameworkResponses
  class BulkUpdateError < StandardError
    attr_reader :errors

    def initialize(errors)
      super
      @errors = errors
    end
  end
end
