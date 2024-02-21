class GenericEvent
  class LodgingCancel < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    eventable_types 'Lodging'
    details_attributes :start_date, :end_date, :cancellation_reason, :cancellation_reason_comment
    relationship_attributes LOCATION_ATTRIBUTE_KEY => :locations

    include LocationValidations
    include LocationFeed

    validates :start_date, presence: true
    validates :end_date, presence: true
    validates :cancellation_reason, inclusion: { in: Lodging::CANCELLATION_REASONS }

    validates_each :start_date, :end_date do |record, attr, value|
      Date.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date')
    end

    def for_feed
      super.tap do |common_feed_attributes|
        # NB: Force cancellation_reason_comment to be present
        common_feed_attributes['details']['cancellation_reason_comment'] = cancellation_reason_comment || ''
      end
    end
  end
end
