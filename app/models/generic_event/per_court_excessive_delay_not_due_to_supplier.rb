class GenericEvent
  class PerCourtExcessiveDelayNotDueToSupplier < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :subtype, :vehicle_reg, :ended_at, :authorised_by, :authorised_at
    relationship_attributes location_id: :locations

    include PersonEscortRecordEventValidations
    include AuthoriserValidations
    include LocationValidations

    enum subtype: {
      making_prisoner_available_for_loading: 'making_prisoner_available_for_loading',
      access_to_or_from_location_when_collecting_dropping_off_prisoner: 'access_to_or_from_location_when_collecting_dropping_off_prisoner',
    }

    validates :subtype, inclusion: { in: subtypes }
    validates :ended_at, presence: true, iso_date_time: true
  end
end
