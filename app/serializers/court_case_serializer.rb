class CourtCaseSerializer < ActiveModel::Serializer
  attributes :nomis_case_id, :nomis_case_status, :case_start_date,
             :case_type, :case_number

  belongs_to :location, serializer: LocationSerializer

  def nomis_case_id
    object.case_id
  end

  def nomis_case_status
    object.case_status
  end

  def case_start_date
    object.begin_date
  end

  def case_number
    object.case_info_number
  end
end
