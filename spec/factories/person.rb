# frozen_string_literal: true

FactoryBot.define do
  factory :person do
    profiles { build_list :profile, 1 }

    trait :nomis_synced do
      sequence(:nomis_prison_number) do |seq|
        number = seq / 26 + 1000
        letter = ('A'..'Z').to_a[seq % 26]
        "T#{number}T#{letter}"
      end
    end
  end
end
