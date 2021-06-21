# frozen_string_literal: true

class Population < ApplicationRecord
  belongs_to :location

  validates :date, presence: true, uniqueness: { scope: :location_id }
  validates :operational_capacity, presence: true, numericality: { greater_than: 0 }
  validates :usable_capacity, presence: true, numericality: { greater_than: 0 }
  validates :unlock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :bedwatch, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :overnights_in, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :overnights_out, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :out_of_area_courts, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :discharges, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def moves_from
    location.moves_from.prison_transfer.not_cancelled.where(date: date)
  end

  def moves_to
    location.moves_to.prison_transfer.not_cancelled.where(date: date)
  end

  def free_spaces
    return unless persisted?

    usable_capacity - unlock - bedwatch - overnights_in - moves_to.count + overnights_out + out_of_area_courts + discharges + moves_from.count
  end

  def save_uniquely!
    save!
    self
  rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique
    errors.add(:date, :taken)
    raise ActiveRecord::RecordInvalid, self
  end

  def self.new_with_defaults(location:, date:)
    # Find most recent population figures for specified location prior to requested date
    previous_population = where(location_id: location.id).where('date < ?', date).order(date: :asc).last

    # Obtain unlock and discharge counts from Nomis
    nomis_counts = Populations::DefaultsFromNomis.call(location, date)

    new(location: location, date: date).tap do |new_population|
      new_population.operational_capacity = previous_population&.operational_capacity
      new_population.usable_capacity = previous_population&.usable_capacity
      new_population.bedwatch = previous_population&.bedwatch
      new_population.overnights_in = previous_population&.overnights_in
      new_population.overnights_out = previous_population&.overnights_out
      new_population.out_of_area_courts = previous_population&.out_of_area_courts

      new_population.unlock = nomis_counts[:unlock]
      new_population.discharges = nomis_counts[:discharges]
    end
  end

  def self.free_spaces_date_range(locations, date_range)
    {}.tap do |locations_hash|
      date_range.each do |date|
        free_spaces_for_date(locations, date).each do |row|
          location_id, population_id, transfers_in, transfers_out, free_spaces_excluding_transfers = *row

          free_space_details = {
            id: population_id,
            free_spaces: (free_spaces_excluding_transfers - transfers_in + transfers_out if population_id.present?),
            transfers_in: transfers_in,
            transfers_out: transfers_out,
          }

          locations_hash[location_id] = [] unless locations_hash.key?(location_id)
          locations_hash[location_id] << free_space_details
        end
      end
    end
  end

  def self.free_spaces_for_date(locations, date)
    locations
      # Join with matching populations for location and given date (if any). Can't use a where clause as there may not be a population record
      .joins(sanitize_sql(['LEFT OUTER JOIN populations p ON p.location_id = locations.id AND p.date = :date', { date: date }]))
      # Join with matching (non cancelled) prison transfers on the given date (if any) so we can count them
      .joins(sanitize_sql(["LEFT OUTER JOIN moves m ON m.move_type = 'prison_transfer' AND m.status <> 'cancelled' AND m.date = :date", { date: date }]))
      # Group by columns used in the free space calculation
      .group(:id, :'p.id')
      # Need to wrap derived columns in pointless Arel.sql call to resolve annoying deprecation warning, even though this is safe :(
      .pluck(Arel.sql('locations.id, p.id, COUNT(m.id) FILTER (WHERE m.to_location_id = locations.id) AS transfers_in, COUNT(m.id) FILTER (WHERE m.from_location_id = locations.id) AS transfers_out, usable_capacity - unlock - bedwatch - overnights_in + overnights_out + out_of_area_courts + discharges AS free_space_excluding_transfers'))
  end

  private_class_method :free_spaces_for_date
end
