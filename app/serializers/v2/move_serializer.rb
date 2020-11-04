# frozen_string_literal: true

module V2
  class MoveSerializer
    include JSONAPI::Serializer

    set_type :moves

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

    has_one :from_location,          serializer: LocationSerializer
    has_one :prison_transfer_reason, serializer: PrisonTransferReasonSerializer
    has_one :profile,                serializer: V2::ProfileSerializer
    has_one :supplier,               serializer: SupplierSerializer
    has_one :to_location,            serializer: LocationSerializer

    has_many :court_hearings, serializer: CourtHearingSerializer
    has_many :timeline_events, serializer: GenericEventSerializer, &:all_events_for_timeline

    belongs_to :allocation, serializer: AllocationSerializer
    belongs_to :original_move, serializer: V2::MoveSerializer

    SUPPORTED_RELATIONSHIPS = %w[
      profile.documents
      profile.person.ethnicity
      profile.person.gender
      profile.person_escort_record
      profile.person_escort_record.flags
      profile.person_escort_record.framework
      profile.person_escort_record.responses
      profile.person_escort_record.prefill_source
      profile.person_escort_record.responses.nomis_mappings
      profile.person_escort_record.responses.question
      profile.person_escort_record.responses.question.descendants.**
      profile.youth_risk_assessment
      profile.youth_risk_assessment.flags
      profile.youth_risk_assessment.framework
      profile.youth_risk_assessment.prefill_source
      profile.youth_risk_assessment.responses
      profile.youth_risk_assessment.responses.nomis_mappings
      profile.youth_risk_assessment.responses.question
      profile.youth_risk_assessment.responses.question.descendants.**
      from_location
      from_location.suppliers
      to_location
      to_location.suppliers
      prison_transfer_reason
      court_hearings
      allocation
      original_move
      supplier
      timeline_events
      timeline_events.eventable
    ].freeze

    INCLUDED_FIELDS = {
      allocation: %i[to_location from_location moves_count created_at],
    }.freeze
  end
end
