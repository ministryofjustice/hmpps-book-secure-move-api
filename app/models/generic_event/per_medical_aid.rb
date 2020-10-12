class GenericEvent
  class PerMedicalAid < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id
    DETAILS_ATTRIBUTES = %w[
      advised_at
      advised_by
      treated_at
      treated_by
      supplier_personnel_number
      vehicle_reg
    ].freeze

    include LocationValidations
    include PersonEscortRecordEventValidations
    include SupplierPersonnelNumberValidations

    validates :advised_at, presence: true
    validates :advised_by, presence: true
    validates :treated_at, presence: true
    validates :treated_by, presence: true

    validates_each :advised_at, :treated_at do |record, attr, value|
      Time.zone.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end

    def advised_at=(advised_at)
      details['advised_at'] = advised_at
    end

    def advised_at
      details['advised_at']
    end

    def advised_by=(advised_by)
      details['advised_by'] = advised_by
    end

    def advised_by
      details['advised_by']
    end

    def treated_at=(treated_at)
      details['treated_at'] = treated_at
    end

    def treated_at
      details['treated_at']
    end

    def treated_by=(treated_by)
      details['treated_by'] = treated_by
    end

    def treated_by
      details['treated_by']
    end

    def vehicle_reg=(vehicle_reg)
      details['vehicle_reg'] = vehicle_reg
    end

    def vehicle_reg
      details['vehicle_reg']
    end
  end
end
