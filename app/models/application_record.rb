# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include UpdatedAtRange
  class << self
    def retriable_transaction(**options, &block)
      retried ||= false
      transaction(**options, &block)
    rescue ActiveRecord::PreparedStatementCacheExpired
      if retried
        raise
      else
        retried = true
        retry
      end
    end
  end
end
