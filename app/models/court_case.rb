class CourtCase
  include ActiveModel::Serialization

  attr_reader :id, :case_id, :case_info_number, :case_seq, :begin_date, :case_type, :case_status, :agency_id

  def build_from_nomis(court_case)
    @id = court_case['id'] # since there is not UUID, we'll use the Nomis ID to identify the CourtCase
    @case_id = @id

    @case_info_number = court_case['caseInfoNumber']
    @case_seq = court_case['caseSeq']
    @begin_date = court_case['beginDate']
    @case_type = court_case['caseType']
    @case_status = court_case['caseStatus']

    @agency_id = court_case['agency']['agencyId']

    self
  end

  def location
    @location ||= Location.find_by nomis_agency_id: @agency_id
  end
end
