class Activity
  include ActiveModel::Serialization

  REASON = 'Prison Activities'.freeze

  attr_reader :id, :start_time, :reason, :type, :agency_id

  def build_from_nomis(activity)
    @id = activity['eventId']
    # Nomis startTime does not include a zone so we shouldn't use our local zone with Time.zone.parse and
    # arbitraily add a timezone
    # rubocop:disable Rails/TimeZone
    @start_time = Time.parse(activity['startTime'])
    # rubocop:enable Rails/TimeZone
    @type = activity['eventTypeDesc']
    @reason = REASON
    @agency_id = activity['locationCode']

    self
  end

  def location
    @location ||= Location.find_by(nomis_agency_id: @agency_id)
  end
end
