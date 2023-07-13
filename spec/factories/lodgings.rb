FactoryBot.define do
  factory :lodging do
    association(:move, factory: :move)
    association(:location, factory: :location)
    start_date { '2023-01-01' }
    end_date { '2023-01-02' }
  end
end
