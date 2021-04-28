class GenericEvent
  class PerCourtHearing < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :is_virtual, :is_trial, :court_listing_at, :started_at, :ended_at, :agreed_at, :court_outcome
    relationship_attributes location_id: :locations
    eventable_types 'PersonEscortRecord'

    validates :is_virtual,       inclusion: [true, false]
    validates :is_trial,         inclusion: [true, false]
    validates :court_listing_at, presence: true, iso_date_time: true
    validates :started_at,       presence: true, iso_date_time: true
    validates :ended_at,         presence: true, iso_date_time: true
    validates :agreed_at,        allow_nil: true, iso_date_time: true
    validates :court_outcome,    presence: true

    include LocationValidations
    include LocationFeed
  end
end
