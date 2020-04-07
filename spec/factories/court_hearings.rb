FactoryBot.define do
  factory :court_hearing do
    move { nil }
    nomis_case_number { 'MyString' }
    court_type { 'MyString' }
    comments { 'MyText' }
    nomis_case_id { 1 }
    nomis_hearing_id { 1 }
    saved_to_nomis { false }
  end
end
