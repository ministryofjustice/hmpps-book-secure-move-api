FactoryBot.define do
  factory :court_hearing do
    start_time { '2018-01-01T18:57Z' }
    case_number { 'T32423423423' }
    case_type { 'Adult' }
    comments { 'Witness for Foo Bar' }
    nomis_case_id { 4_232_423 }
  end

  trait :saved_to_nomis do
    nomis_hearing_id { 1 }
    saved_to_nomis { true }
  end
end
