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
    usable_capacity - unlock - bedwatch - overnights_in - moves_to.count + overnights_out + out_of_area_courts + discharges + moves_from.count
  end

  def save_uniquely!
    save!
    self
  rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique
    errors.add(:date, :taken)
    raise ActiveRecord::RecordInvalid, self
  end

  def self.free_spaces_date_range(locations, date_range)
    {}.tap do |locations_hash|
      date_range.each do |date|
        free_spaces_for_date(locations, date).each do |row|
          location_id, population_id, free_spaces = *row

          free_space_details = { id: population_id, free_spaces: free_spaces } if population_id.present?

          locations_hash[location_id] = [] unless locations_hash.key?(location_id)
          locations_hash[location_id] << free_space_details
        end
      end
    end
  end

  def self.free_spaces_for_date(locations, date)
    locations
      # Join with matching populations for location and given date (if any). Can't use a where clause as there may not be a population record
      .joins(sanitize_sql(['LEFT OUTER JOIN populations p ON p.location_id = locations.id AND p.date = :date', date: date]))
      # Join with matching (non cancelled) prison transfers to the location on the given date (if any) so we can count them
      .joins("LEFT OUTER JOIN moves moves_in ON moves_in.to_location_id = locations.id AND moves_in.move_type = 'prison_transfer' AND moves_in.status <> 'cancelled' AND moves_in.date = p.date")
      # Join with matching (non cancelled) prison transfers from the location on the given date (if any) so we can count them
      .joins("LEFT OUTER JOIN moves moves_out ON moves_out.from_location_id = locations.id AND moves_out.move_type = 'prison_transfer' AND moves_out.status <> 'cancelled' AND moves_out.date = p.date")
      # Group by columns used in the free space calculation
      .group(:id, :'p.id', :usable_capacity, :unlock, :bedwatch, :overnights_in, :overnights_out, :out_of_area_courts, :discharges)
      # Need to wrap derived columns in pointless Arel.sql call to resolve annoying deprecation warning, even though this is safe :(
      .pluck(Arel.sql('locations.id, p.id, usable_capacity - unlock - bedwatch - overnights_in - count(moves_in) + overnights_out + out_of_area_courts + discharges + count(moves_out) as free_space'))
  end

  private_class_method :free_spaces_for_date
end
