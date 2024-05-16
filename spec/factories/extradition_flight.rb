FactoryBot.define do
  factory :extradition_flight do
    association(:move, factory: :move)
    flight_number { 'BA0001' }
    flight_time { '2024-01-01T12:00:00' }
  end
end
