class FastJjsonapi::CourtHearingSerializer
  include FastJsonapi::ObjectSerializer

  belongs_to :move

  attributes :start_time, :case_start_date, :nomis_case_id, :case_number, :nomis_hearing_id, :case_type, :comments, :saved_to_nomis
end
