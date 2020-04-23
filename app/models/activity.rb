class Activity
  include ActiveModel::Serialization

  TYPE = 'Prison Activities'.freeze

  attr_reader :id, :start_time, :reason, :type, :agency_id

  def build_from_nomis(activity)
    @id = activity['eventId']
    @start_time = Time.zone.parse(activity['startTime'])
    @type = TYPE
    @reason = activity['eventTypeDesc']
    @agency_id = activity['locationCode']

    self
  end

  def location
    @location ||= Location.find_by(nomis_agency_id: @agency_id)
  end
end
