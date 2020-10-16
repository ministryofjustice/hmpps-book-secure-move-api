class GenericEvent
  class PerCourtHearing < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :is_virtual, :is_trial, :court_listing_at, :started_at, :ended_at, :agreed_at, :court_outcome

    relationship_attributes :location_id

    eventable_types 'PersonEscortRecord'


    validates :is_virtual,       presence: true
    validates :is_trial,         presence: true
    validates :court_listing_at, presence: true
    validates :started_at,       presence: true
    validates :ended_at,         presence: true
    validates :agreed_at,        presence: true
    validates :court_outcome,    presence: true

    validates :is_virtual,       inclusion: [true, false]
    validates :is_trial,         inclusion: [true, false]

    validates_each :court_listing_at, :started_at, :ended_at, :agreed_at do |record, attr, value|
      Time.zone.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end

    include LocationValidations
  end
end
