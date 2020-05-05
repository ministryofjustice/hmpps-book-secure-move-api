class FastJsonapi::CourtCaseSerializer
  include FastJsonapi::ObjectSerializer

  set_type 'court_cases'

  belongs_to :location, serializer: FastJsonapi::LocationSerializer

  attributes :case_type, :location_id

  attribute :nomis_case_id, &:case_id
  attribute :nomis_case_status, &:case_status
  attribute :case_start_date, &:begin_date
  attribute :case_number, &:case_info_number
end
