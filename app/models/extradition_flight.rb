# frozen_string_literal: true

class ExtraditionFlight < ApplicationRecord
  belongs_to :move

  validates :flight_number, presence: true
  validates :flight_time, presence: true

  validates_each :flight_time do |record, attr, value|
    Date.iso8601(value)
  rescue ArgumentError
    record.errors.add(attr, 'must be formatted as a valid ISO-8601 date')
  end
end
