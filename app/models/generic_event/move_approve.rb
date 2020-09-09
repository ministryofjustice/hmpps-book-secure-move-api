class GenericEvent
  class MoveApprove < GenericEvent
    include MoveEventValidations
    validates :date, presence: true

    validates_each :date do |record, attr, value|
      Date.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date')
    end

    def date
      @date ||= details['date']
    end

    def date=(date)
      details['date'] = date
    end

    def create_in_nomis?
      details.fetch(:create_in_nomis, false)
    end

    def trigger
      eventable.status = Move::MOVE_STATUS_REQUESTED

      eventable.date = date
      Allocations::CreateInNomis.call(eventable) if create_in_nomis?
    end

    def for_feed
      super.tap do |common_feed_attributes|
        # NB: Force create_in_nomis to be true or false
        common_feed_attributes['details']['create_in_nomis'] = create_in_nomis?
      end
    end
  end
end
