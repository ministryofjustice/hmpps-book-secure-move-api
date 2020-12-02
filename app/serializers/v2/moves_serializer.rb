# frozen_string_literal: true

module V2
  class MovesSerializer
    include JSONAPI::Serializer
    include JSONAPI::ConditionalRelationships

    attributes  :additional_information,
                :cancellation_reason,
                :cancellation_reason_comment,
                :created_at,
                :date,
                :date_from,
                :date_to,
                :move_agreed,
                :move_agreed_by,
                :move_type,
                :reference,
                :rejection_reason,
                :status,
                :time_due,
                :updated_at

    set_type :moves

    INCLUDED_FIELDS = {
      # TODO: remove these and replace with conditional relationships in relevant serializer
      people: ::V2::PersonSerializer.attributes_to_serialize.keys + %i[gender ethnicity],
      locations: ::LocationSerializer.attributes_to_serialize.keys,
    }.freeze

    SUPPORTED_RELATIONSHIPS = %w[
      profile.person
      profile.person.ethnicity
      profile.person.gender
      profile.person_escort_record
      profile.person_escort_record.flags
      profile.person_escort_record.medical_events
      from_location
      to_location
      prison_transfer_reason
      supplier
      critical_events
    ].freeze

    belongs_to :from_location, serializer: ::LocationSerializer
    belongs_to :to_location, serializer: ::LocationSerializer
    belongs_to :profile, serializer: V2::ProfilesSerializer
    belongs_to :prison_transfer_reason, serializer: PrisonTransferReasonSerializer
    belongs_to :supplier, serializer: SupplierSerializer
    belongs_to :allocation, serializer: AllocationSerializer

    has_many_if_included :critical_events, serializer: ImportantEventsSerializer
  end
end
