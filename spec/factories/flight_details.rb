FactoryBot.define do
  factory :flight_details do
    association(:move, factory: :move)
    flight_number { 'BA0001' }
    flight_time { '2024-01-01T12:00:00' }
  end
end
