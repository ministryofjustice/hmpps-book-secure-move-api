class GenericEvent
  class PerCourtExcessiveDelayNotDueToSupplier < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :subtype, :vehicle_reg, :ended_at, :authorised_by, :authorised_at
    relationship_attributes :location_id

    include PersonEscortRecordEventValidations
    include AuthoriserValidations
    include LocationValidations

    enum subtype: {
      making_prisoner_available_for_loading: 'making_prisoner_available_for_loading',
      access_to_or_from_location_when_collecting_dropping_off_prisoner: 'access_to_or_from_location_when_collecting_dropping_off_prisoner',
    }

    validates :subtype, inclusion: { in: subtypes }
    validates :ended_at, presence: true
    validates_each :ended_at do |record, attr, value|
      Time.zone.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end
  end
end
