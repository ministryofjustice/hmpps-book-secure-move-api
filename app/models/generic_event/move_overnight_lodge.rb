class GenericEvent
  class MoveOvernightLodge < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :start_date, :end_date
    relationship_attributes LOCATION_ATTRIBUTE_KEY => :locations
    eventable_types 'Move'

    validates :start_date, presence: true
    validates :end_date, presence: true

    validates_each :start_date, :end_date do |record, attr, value|
      Date.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date')
    end

    validate :end_date_after_start_date

    include LocationValidations
    include LocationFeed

    def location
      Location.find_by(id: location_id)
    end

  private

    def end_date_after_start_date
      return if start_date.blank? || end_date.blank?

      if Date.parse(end_date) <= Date.parse(start_date)
        errors.add(:end_date, 'must be after start_date')
      end
    end
  end
end
