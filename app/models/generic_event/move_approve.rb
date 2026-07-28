class GenericEvent
  class MoveApprove < GenericEvent
    details_attributes :date
    eventable_types 'Move'

    validates :date, presence: true

    validates_each :date do |record, attr, value|
      Date.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date')
    end

    def trigger(*)
      eventable.approve(date:)
    end
  end
end
