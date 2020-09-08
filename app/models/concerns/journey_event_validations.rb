require 'active_support/concern'

module JourneyEventValidations
  extend ActiveSupport::Concern

  EVENTABLE_TYPES = %w[Journey].freeze

  included do
    validates :eventable_type, inclusion: { in: EVENTABLE_TYPES }
  end
end
