# frozen_string_literal: true

FactoryBot.define do
  factory :supplier_location do
    association(:supplier)
    association(:location)
  end
end
