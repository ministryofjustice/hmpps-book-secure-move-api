FactoryBot.define do
  factory :population do
    association(:location)

    sequence(:date) { |n| Date.today + n.days }
    operational_capacity { Faker::Number.between(from: 200, to: 500) }
    usable_capacity { Faker::Number.between(from: 250, to: 450) }
    unlock { Faker::Number.between(from: 300, to: 400) }
    bedwatch { Faker::Number.between(from: 1, to: 10) }
    overnights_in { Faker::Number.between(from: 1, to: 10) }
    overnights_out { Faker::Number.between(from: 1, to: 10) }
    out_of_area_courts { Faker::Number.between(from: 1, to: 10) }
    discharges { Faker::Number.between(from: 1, to: 10) }
    updated_by { Faker::Name.name }

    trait :with_moves_from do
      after(:create) do |population|
        create(
          :move,
          :prison_transfer,
          from_location: population.location,
          date: population.date,
        )
      end
    end

    trait :with_moves_to do
      after(:create) do |population|
        create(
          :move,
          :prison_transfer,
          to_location: population.location,
          date: population.date,
        )
      end
    end
  end
end
