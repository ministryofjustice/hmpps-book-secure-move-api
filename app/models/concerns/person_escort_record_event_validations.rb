require 'active_support/concern'

module PersonEscortRecordEventValidations
  extend ActiveSupport::Concern

  EVENTABLE_TYPES = %w[PersonEscortRecord].freeze

  included do
    validates :eventable_type, inclusion: { in: EVENTABLE_TYPES }
  end
end
