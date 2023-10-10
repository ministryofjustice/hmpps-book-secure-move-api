class GenericEvent
  class MoveApprove < GenericEvent
    details_attributes :date, :create_in_nomis
    eventable_types 'Move'

    validates :date, presence: true

    validates_each :date do |record, attr, value|
      Date.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date')
    end

    def trigger(dry_run: false)
      eventable.approve(date:)

      Allocations::CreateInNomis.call(eventable) if !dry_run && create_in_nomis
    end

    def for_feed
      super.tap do |common_feed_attributes|
        # NB: Force create_in_nomis to be true or false
        common_feed_attributes['details']['create_in_nomis'] = create_in_nomis || false
      end
    end
  end
end
