FactoryBot.define do
  factory :court_hearing do
    start_time { '2018-01-01T18:57Z' }
    nomis_case_number { 'MyString' }
    case_type { 'MyString' }
    comments { 'MyText' }
    nomis_case_id { 1 }
  end

  trait :saved_to_nomis do
    nomis_hearing_id { 1 }
    saved_to_nomis { false }
  end
end
