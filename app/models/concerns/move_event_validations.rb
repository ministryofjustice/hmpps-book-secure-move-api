require 'active_support/concern'

module MoveEventValidations
  extend ActiveSupport::Concern

  EVENTABLE_TYPES = %w[Move].freeze

  included do
    validates :eventable_type, inclusion: { in: EVENTABLE_TYPES }
  end
end
