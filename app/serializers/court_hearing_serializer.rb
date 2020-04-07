class CourtHearingSerializer < ActiveModel::Serializer
  attributes :nomis_case_id, :nomis_case_number, :nomis_hearing_id, :court_type, :comments, :saved_to_nomis
end
