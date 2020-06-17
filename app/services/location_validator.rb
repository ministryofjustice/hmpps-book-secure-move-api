# frozen_string_literal: true

class LocationValidator < ActiveModel::Validator
  def validate(record)
    options[:locations].each do |location_id_field|
      # check if location is not nil and exists
      location_id = record.send(location_id_field)
      if location_id.nil?
        record.errors.add(location_id_field, 'is missing')
      elsif !Location.exists?(location_id)
        record.errors.add(location_id_field, 'was not found')
      end
    end
  end
end
