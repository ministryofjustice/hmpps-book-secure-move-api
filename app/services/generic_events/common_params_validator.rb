# frozen_string_literal: true

module GenericEvents
  class CommonParamsValidator
    include ActiveModel::Validations

    attr_reader :occurred_at, :recorded_at, :event_type

    validates :occurred_at, presence: true
    validates :recorded_at, presence: true

    %i[occurred_at recorded_at].each do |field|
      validates_each field do |record, attr, value|
        Time.zone.iso8601(value)
      rescue ArgumentError
        record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
      end
    end

    validates :event_type, presence: true, inclusion: { in: GenericEvent::STI_CLASSES }

    def initialize(event_params)
      @occurred_at = event_params.dig('attributes', 'occurred_at')
      @recorded_at = event_params.dig('attributes', 'recorded_at')
      @event_type = event_params.dig('attributes', 'event_type')
    end
  end
end
