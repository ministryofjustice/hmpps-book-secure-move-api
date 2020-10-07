class GenericEvent
  class PerCourtExcessiveDelayNotDueToSupplier < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id
    DETAILS_ATTRIBUTES = %w[
      subtype
      vehicle_reg
      ended_at
    ].freeze

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

    def ended_at=(ended_at)
      details['ended_at'] = ended_at
    end

    def ended_at
      details['ended_at']
    end

    def subtype=(subtype)
      details['subtype'] = subtype
    end

    def subtype
      details['subtype']
    end

    def vehicle_reg=(vehicle_reg)
      details['vehicle_reg'] = vehicle_reg
    end

    def vehicle_reg
      details['vehicle_reg']
    end
  end
end
