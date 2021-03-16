# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary_replica }

  scope :created_at_range, ->(from, to) { where(created_at: from..to) }
  scope :updated_at_range, ->(from, to) { where(updated_at: from..to) }

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
