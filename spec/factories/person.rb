# frozen_string_literal: true

FactoryBot.define do
  factory :person do
    association(:ethnicity)
    association(:gender)

    profiles { build_list :profile, 1 }

    first_names { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    date_of_birth { Date.new(1980, 10, 20) }

    sequence(:police_national_computer) { |seq| sprintf('AB/%07d', seq) }
    sequence(:prison_number)            { |seq| sprintf('D%04dZZ', seq) }
    sequence(:criminal_records_office)  { |seq| sprintf('CRO/%05d', seq) }
  end

  factory :person_without_profiles, class: 'Person' do
    association(:ethnicity)
    association(:gender)

    date_of_birth { Date.new(1980, 10, 20) }

    sequence(:police_national_computer) { |seq| sprintf('AB/%07d', seq) }
    sequence(:prison_number)            { |seq| sprintf('D%04dZZ', seq) }
    sequence(:criminal_records_office)  { |seq| sprintf('CRO/%05d', seq) }

    first_names { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end

  trait :nomis_synced do
    sequence(:nomis_prison_number) do |seq|
      number = seq / 26 + 1000
      letter = ('A'..'Z').to_a[seq % 26]
      "T#{number}T#{letter}"
    end
  end
end
