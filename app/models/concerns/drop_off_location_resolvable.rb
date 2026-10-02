# Resolves the effective drop-off location for a Move-scoped event to the move's
# `to_location` (its final, whole-journey destination).
module DropOffLocationResolvable
  extend ActiveSupport::Concern

  included do
    before_validation :assign_location_id
  end

private

  def assign_location_id
    return unless self.class.eventable_types.include?(eventable_type)

    self.location_id ||= move&.to_location&.id
  end
end
