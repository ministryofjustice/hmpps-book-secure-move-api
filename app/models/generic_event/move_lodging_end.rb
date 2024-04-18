class GenericEvent
  class MoveLodgingEnd < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    relationship_attributes location_id: :locations
    eventable_types 'Move'

    include LocationValidations
    include LocationFeed

    def trigger(dry_run: false)
      return if dry_run

      lodging&.complete
      lodging&.save!
    end

  private

    def lodging
      @lodging ||= eventable.lodgings.find_by(location_id:, start_date: occurred_at.to_date)
    end
  end
end
