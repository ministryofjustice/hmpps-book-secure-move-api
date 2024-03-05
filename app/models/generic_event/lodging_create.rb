class GenericEvent
  class LodgingCreate < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    eventable_types 'Lodging'
    details_attributes :start_date, :end_date
    relationship_attributes LOCATION_ATTRIBUTE_KEY => :locations

    include LocationValidations
    include LocationFeed

    validates :start_date, presence: true
    validates :end_date, presence: true

    validates_each :start_date, :end_date do |record, attr, value|
      Date.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date')
    end
  end
end
