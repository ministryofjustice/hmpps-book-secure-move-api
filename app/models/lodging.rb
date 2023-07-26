class Lodging < ApplicationRecord
  validates :move, presence: true
  validates :location, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  validates_each :start_date, :end_date do |record, attr, value|
    Date.iso8601(value)
  rescue ArgumentError
    record.errors.add(attr, 'must be formatted as a valid ISO-8601 date')
  end

  validate :end_date_after_start_date

  belongs_to :move, touch: true
  belongs_to :location

private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    if Date.parse(end_date) <= Date.parse(start_date)
      errors.add(:end_date, 'must be after start_date')
    end
  end
end
