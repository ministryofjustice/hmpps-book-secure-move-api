# frozen_string_literal: true

module GenericEvents
  class CommonParamsValidator
    include ActiveModel::Validations

    EVENTABLE_TYPES = %w[
      moves
      people
      person_escort_records
      profiles
      journeys
    ].freeze

    attr_reader :occurred_at, :recorded_at, :event_type, :eventable_type

    validates :occurred_at,    presence: true, iso_date_time: true
    validates :recorded_at,    presence: true, iso_date_time: true
    validates :event_type,     presence: true
    validates :eventable_type, presence: true

    validates_inclusion_of :event_type, in: GenericEvent::STI_CLASSES, message: "'%{value}' is not a valid event_type"
    validates_inclusion_of :eventable_type, in: EVENTABLE_TYPES, message: "'%{value}' is not a valid eventable type"

    def initialize(event_params, event_relationships)
      @occurred_at = event_params.dig('attributes', 'occurred_at')
      @recorded_at = event_params.dig('attributes', 'recorded_at')
      @event_type = event_params.dig('attributes', 'event_type')
      @eventable_type = event_relationships.dig('eventable', 'data', 'type')
    end
  end
end
