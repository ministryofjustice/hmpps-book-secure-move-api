# frozen_string_literal: true

module V2
  class MovesSerializer
    include JSONAPI::Serializer

    INCLUDED_ATTRIBUTES = %i[
      additional_information
      cancellation_reason
      cancellation_reason_comment
      created_at
      date
      date_from
      date_to
      move_agreed
      move_agreed_by
      move_type
      reference
      rejection_reason
      status
      time_due
      updated_at
    ].freeze

    INCLUDED_FIELDS = {
      moves: INCLUDED_ATTRIBUTES +
        %i[profile from_location to_location prison_transfer_reason supplier additional_information],
      profiles: ::V2::ProfileSerializer::INCLUDED_ATTRIBUTES + %i[person],
      people: ::V2::PersonSerializer::INCLUDED_ATTRIBUTES + %i[gender ethnicity],
      locations: ::LocationSerializer::INCLUDED_ATTRIBUTES,
      prison_transfer_reasons: ::PrisonTransferReasonSerializer::INCLUDED_ATTRIBUTES,
      suppliers: ::SupplierSerializer::INCLUDED_ATTRIBUTES,

      # allocation: %i[to_location from_location moves_count created_at],
    }.freeze

    SUPPORTED_RELATIONSHIPS = %w[
      profile.person.ethnicity
      profile.person.gender
      from_location
      to_location
      prison_transfer_reason
      supplier
    ].freeze

    set_type :moves

    attributes(*INCLUDED_ATTRIBUTES)

    has_one :profile, serializer: V2::ProfileSerializer
    has_one :from_location, serializer: ::LocationSerializer
    has_one :to_location, serializer: ::LocationSerializer
    has_one :prison_transfer_reason, serializer: PrisonTransferReasonSerializer
    has_one :supplier, serializer: SupplierSerializer
  end
end
