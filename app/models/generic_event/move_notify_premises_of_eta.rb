class GenericEvent
  class MoveNotifyPremisesOfEta < GenericEvent
    include MoveEventValidations

    validates :expected_at, presence: true

    validates_each :expected_at do |record, attr, value|
      Time.zone.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end

    def expected_at=(expected_at)
      details['expected_at'] = expected_at
    end

    def expected_at
      details['expected_at']
    end
  end
end
