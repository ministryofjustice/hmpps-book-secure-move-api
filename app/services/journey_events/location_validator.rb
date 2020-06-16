# frozen_string_literal: true

module JourneyEvents
  class LocationValidator < ActiveModel::Validator
    def validate(record)
      options[:locations].each do |location_id_field|
        # check if location is not nil and exists
        location_id = record.send(location_id_field)
        if location_id.nil?
          record.errors.add(location_id_field, 'is missing')
        elsif !Location.where(id: location_id).exists?
          record.errors.add(location_id_field, 'was not found')
        end
      end
    end
  end
end
