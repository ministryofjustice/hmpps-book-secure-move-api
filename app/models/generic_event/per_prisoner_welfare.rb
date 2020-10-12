class GenericEvent
  class PerPrisonerWelfare < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id
    DETAILS_ATTRIBUTES = %w[
      given_at
      outcome
      subtype
      supplier_personnel_number
      vehicle_reg
    ].freeze

    enum outcome: {
      accepted: 'accepted',
      refused: 'refused',
    }

    enum subtype: {
      comfort_break: 'comfort_break',
      food: 'food',
      beverage: 'beverage',
      additional_clothing: 'additional_clothing',
      relevant_information_given: 'relevant_information_given',
      miscellaneous_welfare: 'miscellaneous_welfare',
    }

    include LocationValidations
    include PersonEscortRecordEventValidations
    include SupplierPersonnelNumberValidations

    validates :given_at, presence: true

    validates :outcome, inclusion: { in: outcomes }
    validates :subtype, inclusion: { in: subtypes }

    validates_each :given_at do |record, attr, value|
      Time.zone.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end

    def given_at=(given_at)
      details['given_at'] = given_at
    end

    def given_at
      details['given_at']
    end

    def outcome=(outcome)
      details['outcome'] = outcome
    end

    def outcome
      details['outcome']
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
