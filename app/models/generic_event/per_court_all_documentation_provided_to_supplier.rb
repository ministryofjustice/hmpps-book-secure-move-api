class GenericEvent
  class PerCourtAllDocumentationProvidedToSupplier < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      subtype
    ].freeze

    include PersonEscortRecordEventValidations

    enum subtype: {
      extradition_order: 'extradition_order',
      warrant: 'warrant',
      placement_confirmation: 'placement_confirmation',
    }

    validates :subtype, inclusion: { in: subtypes }
    validates :court_location_id, presence: true

    def court_location_id=(court_location_id)
      details['court_location_id'] = court_location_id
    end

    def court_location_id
      details['court_location_id']
    end

    def subtype=(subtype)
      details['subtype'] = subtype
    end

    def subtype
      details['subtype']
    end
  end
end
