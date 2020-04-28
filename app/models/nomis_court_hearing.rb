class NomisCourtHearing
  include ActiveModel::Serialization

  TYPE = 'Court'.freeze
  REASON = 'Court appearance'.freeze

  attr_reader :id, :start_time, :reason, :type, :agency_id

  def build_from_nomis(court_hearing)
    @id = court_hearing['id']
    @start_time = Time.zone.parse(court_hearing['dateTime'])
    @reason = REASON
    @type = TYPE
    @agency_id = court_hearing['location']['agencyId']

    self
  end

  def location
    @location ||= Location.find_by(nomis_agency_id: @agency_id)
  end
end
