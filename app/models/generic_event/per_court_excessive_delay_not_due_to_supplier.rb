class GenericEvent
  class PerCourtExcessiveDelayNotDueToSupplier < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      subtype
      vehicle_reg
    ].freeze

    include PersonEscortRecordEventValidations
    include AuthoriserValidations

    enum subtype: {
      making_prisoner_available_for_loading: 'making_prisoner_available_for_loading',
      access_to_or_from_location_when_collecting_dropping_off_prisoner: 'access_to_or_from_location_when_collecting_dropping_off_prisoner',
    }

    validates :subtype, inclusion: { in: subtypes}

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
