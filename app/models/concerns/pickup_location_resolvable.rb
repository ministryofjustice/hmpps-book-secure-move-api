# Resolves the effective pickup location for a Move-scoped event, accounting for
# any overnight lodge the person is currently staying at. Without this, a Move's
# `from_location` (its original, whole-journey origin) is used for every leg, which
# is wrong once the person has been picked up from an intermediate lodge location.
module PickupLocationResolvable
  extend ActiveSupport::Concern

  included do
    before_validation :assign_location_id
  end

private

  def assign_location_id
    return unless self.class.eventable_types.include?(eventable_type)

    self.location_id ||= current_pickup_location&.id
  end

  def current_pickup_location
    active_lodging&.location || move&.from_location
  end

  def active_lodging
    return if move.nil? || occurred_at.nil?

    date = occurred_at.to_date

    move.lodgings.default_order.to_a.reverse.find do |lodging|
      %w[started completed].include?(lodging.status) &&
        Date.iso8601(lodging.start_date) <= date &&
        date <= Date.iso8601(lodging.end_date)
    end
  end
end
