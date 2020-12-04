# frozen_string_literal: true

class CourtCaseSerializer
  include JSONAPI::Serializer

  set_type :court_cases

  attributes :case_type

  attribute :nomis_case_id, &:case_id
  attribute :nomis_case_status, &:case_status
  attribute :case_start_date, &:begin_date
  attribute :case_number, &:case_info_number

  belongs_to :location, &:location
end
