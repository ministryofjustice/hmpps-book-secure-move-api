# frozen_string_literal: true

class SupplierLocation < ApplicationRecord
  belongs_to :supplier
  belongs_to :location

  validate :effective_to_after_effective_from

  scope :location, ->(location_id) { where(location_id: location_id) }
  scope :effective_from, ->(date) { where(effective_from: nil).or(where('effective_from <= ?', date)) }
  scope :effective_to, ->(date) { where(effective_to: nil).or(where('effective_to >= ?', date)) }
  scope :effective_on, ->(date) { effective_from(date).effective_to(date) }

  def self.link_locations(supplier:, locations:, effective_from: nil, effective_to: nil)
    locations.each do |location|
      create!(effective_from: effective_from, effective_to: effective_to, supplier: supplier, location: location)
    end
  end

private

  def effective_to_after_effective_from
    if effective_from.present? && effective_to.present? && (effective_to < effective_from)
      errors.add(:effective_to, 'must be after effective from')
    end
  end
end
