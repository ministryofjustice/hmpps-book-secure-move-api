class GenericEvent
  class LodgingUpdate < GenericEvent
    LOCATION_ATTRIBUTE_KEYS = %i[old_location_id location_id].freeze

    eventable_types 'Lodging'
    details_attributes :old_start_date, :start_date, :old_end_date, :end_date
    relationship_attributes(LOCATION_ATTRIBUTE_KEYS.index_with { :locations })

    include LocationFeed

    validate :any_value_present
    validate :old_values_present

  private

    def any_value_present
      if location_id.blank? && start_date.blank? && end_date.blank?
        errors.add(:location_id, 'must be present if start_date or end_date are not present')
        errors.add(:start_date, 'must be present if location_id or end_date are not present')
        errors.add(:end_date, 'must be present if start_date or location_id are not present')
      end
    end

    def old_values_present
      %i[location_id start_date end_date].each do |attr|
        if send(attr).present? && send("old_#{attr}").blank?
          errors.add("old_#{attr}", "must be present with #{attr}")
        end
      end
    end

    validates_each %i[old_start_date start_date old_end_date end_date] do |record, attr, value|
      Date.iso8601(value) if value.present?
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date')
    end
  end
end
