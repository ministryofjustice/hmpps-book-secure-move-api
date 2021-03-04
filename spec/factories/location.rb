# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    sequence(:key) { |x| "key_#{x}" }
    title { "HMP #{Faker::Address.city}" }
    location_type { Location::LOCATION_TYPE_PRISON }
    nomis_agency_id { 'PEI' }

    trait :inactive do
      disabled_at { Time.zone.now }
    end

    trait :with_moves do
      after(:create) do |location, _|
        create_list :move, 2, from_location: location
      end
    end

    trait :with_address do
      premise { 'The Big Building' }
      locality { 'District 9' }
      city { Faker::Address.city }
      country { 'England' }
      postcode { 'B1 2JP' }
    end

    trait :with_coordinates do
      latitude { 51.4992813 }
      longitude { -0.1363143 }
    end

    trait :prison do
      # This is already the default
    end

    trait :court do
      sequence(:key) { |x| "court_#{x}" }
      title { "#{Faker::Address.city} Crown Court" }
      location_type { Location::LOCATION_TYPE_COURT }
      nomis_agency_id { 'GUICCT' }
    end

    trait :high_security_hospital do
      sequence(:key) { |x| "secure_hospital_#{x}" }
      title { "#{Faker::Address.city} Secure Hospital" }
      location_type { Location::LOCATION_TYPE_HIGH_SECURITY_HOSPITAL }
      nomis_agency_id { 'GUISH' }
    end

    trait :hospital do
      sequence(:key) { |x| "hospital_#{x}" }
      title { "#{Faker::Address.city} Hospital" }
      location_type { Location::LOCATION_TYPE_HOSPITAL }
      nomis_agency_id { 'GUIHOSP' }
    end

    trait :police do
      sequence(:key) { |x| "police_station_#{x}" }
      title { "#{Faker::Address.city} Police Station" }
      location_type { Location::LOCATION_TYPE_POLICE }
      nomis_agency_id { 'GUIPS' }
    end

    trait :sch do
      sequence(:key) { |x| "secure_childrens_home_#{x}" }
      title { "#{Faker::Address.city} Secure Childrens Home" }
      location_type { Location::LOCATION_TYPE_SECURE_CHILDRENS_HOME }
      nomis_agency_id { 'GUISCH' }
    end

    trait :stc do
      sequence(:key) { |x| "secure_training_centre_#{x}" }
      title { "#{Faker::Address.city} Secure Training Centre" }
      location_type { Location::LOCATION_TYPE_SECURE_TRAINING_CENTRE }
      nomis_agency_id { 'GUISTC' }
    end

    trait :with_suppliers do
      suppliers { [create(:supplier)] }
    end
  end
end
