class CourtCase
  include ActiveModel::Serialization

  attr_reader :id, :case_seq, :begin_date, :case_type, :case_info_number, :case_status, :agency_id

  def build_from_nomis(court_case)

    @case_info_number = court_case['caseInfoNumber']
    @id = @case_info_number

    @case_seq = court_case['caseSeq']
    @begin_date = court_case['beginDate']
    @case_type = court_case['caseType']
    @case_status = court_case['caseStatus']

    @agency_id = court_case['agency']['agencyId']

    self
  end

  def location_id
    location = Location.find_by nomis_agency_id: @agency_id
    if location
      location.id
    end
  end

  def location
    location = Location.find_by nomis_agency_id: @agency_id

    if location
      LocationSerializer.new(location)
    end
  end
end
