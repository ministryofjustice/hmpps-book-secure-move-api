class GenericEvent
  class PerCourtAllDocumentationProvidedToSupplier < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :court_location_id

    details_attributes :subtype
    relationship_attributes court_location_id: :locations
    eventable_types 'PersonEscortRecord'

    include LocationValidations
    include LocationFeed

    attribute :subtype, :string
    enum subtype: {
      extradition_order: 'extradition_order',
      warrant: 'warrant',
      placement_confirmation: 'placement_confirmation',
    }

    validates :subtype, inclusion: { in: subtypes }
  end
end
