class GenericEvent
  class PerPrisonerWelfare < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :given_at, :outcome, :subtype, :vehicle_reg, :supplier_personnel_number
    relationship_attributes location_id: :locations
    eventable_types 'PersonEscortRecord'

    enum outcome: {
      accepted: 'accepted',
      refused: 'refused',
    }

    enum subtype: {
      comfort_break: 'comfort_break',
      food: 'food',
      beverage: 'beverage',
      additional_clothing: 'additional_clothing',
      relevant_information_given: 'relevant_information_given',
      miscellaneous_welfare: 'miscellaneous_welfare',
    }

    include LocationValidations
    include PersonnelNumberValidations
    include LocationFeed

    validates :given_at, presence: true, iso_date_time: true

    validates :outcome, inclusion: { in: outcomes }
    validates :subtype, inclusion: { in: subtypes }
  end
end
