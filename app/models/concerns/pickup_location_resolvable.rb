# Resolves the effective pickup location for a Move-scoped event, accounting for
# any overnight lodge the person is currently staying at. Without this, a Move's
# `from_location` (its original, whole-journey origin) is used for every leg, which
# is wrong once the person has been picked up from an intermediate lodge location.
#

module PickupLocationResolvable
  extend ActiveSupport::Concern

  MOVE_LODGING_START_TYPE = 'GenericEvent::MoveLodgingStart'.freeze

  included do
    before_validation :assign_location_id
  end

private

  def assign_location_id
    return unless self.class.eventable_types.include?(eventable_type)

    self.location_id ||= current_pickup_location&.id
  end

  def current_pickup_location
    previous_lodging_start&.location || move&.from_location
  end

  def previous_lodging_start
    return if move.nil? || pickup_time.nil?

    move.generic_events
        .where(type: MOVE_LODGING_START_TYPE)
        .where('occurred_at <= ?', pickup_time)
        .order(occurred_at: :desc)
        .first
  end

  def pickup_time
    parsed_expected_at || occurred_at
  end

  def parsed_expected_at
    return if expected_at.blank?

    Time.zone.iso8601(expected_at)
  rescue ArgumentError
    nil
  end
end
