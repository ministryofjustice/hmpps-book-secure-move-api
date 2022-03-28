class DifferentToFromLocationValidator < ActiveModel::Validator
  def validate(record)
    return if record.to_location_id.blank?
    return if record.from_location_id.blank?
    return if record.to_location_id != record.from_location_id

    record.errors.add(:to_location_id, 'should be different to the from location')
  end
end
