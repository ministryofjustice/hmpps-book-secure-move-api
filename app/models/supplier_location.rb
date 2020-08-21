# frozen_string_literal: true

class SupplierLocation < ApplicationRecord
  belongs_to :supplier
  belongs_to :location

  validate :effective_to_after_effective_from

  def self.link_locations(effective_from: nil, effective_to: nil, supplier:, locations:)
    locations.each do |location|
      create!(effective_from: effective_from, effective_to: effective_to, supplier: supplier, location: location)
    end
  end

private

  def effective_to_after_effective_from
    if effective_from.present? && effective_to.present?
      if effective_to < effective_from
        errors.add(:effective_to, 'must be after effective from')
      end
    end
  end
end
