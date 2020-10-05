# frozen_string_literal: true

class TimetableSerializer
  include JSONAPI::Serializer

  set_type :timetable_entries

  attributes :start_time, :reason
  attribute :nomis_type, &:type

  belongs_to :location, &:location
end
