# frozen_string_literal: true

module V2
  class MoveSerializer < ActiveModel::Serializer
    attributes :additional_information,
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

    has_one :profile, serializer: V2::ProfileSerializer
    has_one :from_location, serializer: LocationSerializer
    has_one :to_location, serializer: LocationSerializer
    has_one :prison_transfer_reason, serializer: PrisonTransferReasonSerializer

    has_many :court_hearings, serializer: CourtHearingSerializer

    belongs_to :allocation, serializer: AllocationSerializer
    belongs_to :original_move, serializer: MoveSerializer

    SUPPORTED_RELATIONSHIPS = %w[
      profile.documents
      profile.person.ethnicity
      profile.person.gender
      from_location
      from_location.suppliers
      to_location
      to_location.suppliers
      prison_transfer_reason
      court_hearings
      allocation
      original_move
    ].freeze

    INCLUDED_FIELDS = {
      allocation: %i[to_location from_location moves_count created_at],
    }.freeze
  end
end

