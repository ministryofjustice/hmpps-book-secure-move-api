# frozen_string_literal: true

module Moves
  class StatusValidator
    include ActiveModel::Validations

    attr_reader :status, :cancellation_reason, :rejection_reason

    validates_each :cancellation_reason, :rejection_reason, allow_nil: true do |record, attr, value|
      values = value&.split(',') || []
      if (values - Move.const_get(attr.to_s.pluralize.upcase)).any?
        record.errors.add(attr, :inclusion)
      end
    end

    validates :cancellation_reason, presence: true, if: -> { status_cancelled? && rejection_reason_blank? }
    validates :status, inclusion: { in: Move.statuses }, allow_nil: true

    def initialize(status:, cancellation_reason: nil, rejection_reason: nil)
      @status = status
      @cancellation_reason = cancellation_reason
      @rejection_reason = rejection_reason
    end

    def status_cancelled?
      status.to_s == 'cancelled'
    end

    delegate :blank?, to: :rejection_reason, prefix: true
  end
end
