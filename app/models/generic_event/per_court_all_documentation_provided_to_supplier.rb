class GenericEvent
  class PerCourtAllDocumentationProvidedToSupplier < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :court_location_id
    DETAILS_ATTRIBUTES = %w[
      subtype
    ].freeze

    include PersonEscortRecordEventValidations
    include LocationValidations

    enum subtype: {
      extradition_order: 'extradition_order',
      warrant: 'warrant',
      placement_confirmation: 'placement_confirmation',
    }

    validates :subtype, inclusion: { in: subtypes }

    def subtype=(subtype)
      details['subtype'] = subtype
    end

    def subtype
      details['subtype']
    end
  end
end
