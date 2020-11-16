# frozen_string_literal: true

module V2
  class MovesSerializer
    include JSONAPI::Serializer

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
      moves: attributes_to_serialize.keys +
        %i[profile from_location to_location prison_transfer_reason supplier],
      profiles: ::V2::ProfileSerializer.attributes_to_serialize.keys + %i[person person_escort_record person_escort_record_flags],
      people: ::V2::PersonSerializer.attributes_to_serialize.keys + %i[gender ethnicity],
      locations: ::LocationSerializer.attributes_to_serialize.keys,
      prison_transfer_reasons: ::PrisonTransferReasonSerializer.attributes_to_serialize.keys,
      suppliers: ::SupplierSerializer.attributes_to_serialize.keys,
      allocations: ::AllocationSerializer.attributes_to_serialize.keys,
    }.freeze

    SUPPORTED_RELATIONSHIPS = %w[
      profile.person
      profile.person.ethnicity
      profile.person.gender
      profile.person_escort_record
      profile.person_escort_record.flags
      profile.person_escort_record.framework
      profile.person_escort_record.responses
      profile.person_escort_record_flags
      from_location
      to_location
      prison_transfer_reason
      supplier
      allocation
    ].freeze

    has_one :profile, serializer: V2::ProfileSerializer
    has_one :from_location, serializer: ::LocationSerializer
    has_one :to_location, serializer: ::LocationSerializer
    has_one :prison_transfer_reason, serializer: PrisonTransferReasonSerializer
    has_one :supplier, serializer: SupplierSerializer
    has_one :allocation, serializer: AllocationSerializer
  end
end
