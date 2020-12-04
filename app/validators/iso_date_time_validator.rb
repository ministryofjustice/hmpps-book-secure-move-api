class IsoDateTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    Time.zone.iso8601(value)
  rescue ArgumentError
    record.errors.add(attribute, 'must be formatted as a valid ISO-8601 date-time')
  end
end
