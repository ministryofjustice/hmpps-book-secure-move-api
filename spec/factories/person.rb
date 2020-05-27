# frozen_string_literal: true

FactoryBot.define do
  factory :person do
    association(:ethnicity)
    association(:gender)

    profiles { build_list :profile, 1 }

    first_names { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    date_of_birth { Date.new(1980, 10, 20) }

    police_national_computer { 'AB/1234567' }
    prison_number { 'D39067ZZ' }
    criminal_records_office { 'CRO/74506' }

    trait :nomis_synced do
      sequence(:nomis_prison_number) do |seq|
        number = seq / 26 + 1000
        letter = ('A'..'Z').to_a[seq % 26]
        "T#{number}T#{letter}"
      end
    end
  end

  factory :person_without_profiles, class: 'Person' do
    first_names { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end
end
