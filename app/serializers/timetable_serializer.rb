class TimetableSerializer < ActiveModel::Serializer
  type 'timetable_entries'

  attributes :start_time, :reason, :nomis_type

  belongs_to :location, serializer: LocationSerializer

  def nomis_type
    object.type
  end
end
