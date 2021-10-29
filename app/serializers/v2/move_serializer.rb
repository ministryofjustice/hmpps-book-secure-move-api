# frozen_string_literal: true

module V2
  class MoveSerializer
    include JSONAPI::Serializer
    include JSONAPI::ConditionalRelationships

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

    belongs_to :from_location,          serializer: LocationSerializer
    belongs_to :prison_transfer_reason, serializer: PrisonTransferReasonSerializer
    belongs_to :profile,                serializer: V2::ProfileSerializer
    belongs_to :supplier,               serializer: SupplierSerializer
    belongs_to :to_location,            serializer: LocationSerializer

    has_many :court_hearings, serializer: CourtHearingSerializer
    has_many_if_included :journeys, serializer: JourneySerializer

    has_many_if_included :timeline_events, serializer: ->(record, _params) { record.class.serializer }, &:all_events_for_timeline
    has_many_if_included :important_events, serializer: ImportantEventsSerializer, &:important_events

    belongs_to :allocation, serializer: AllocationSerializer
    belongs_to :original_move, serializer: V2::MoveSerializer

    SUPPORTED_RELATIONSHIPS = %w[
      profile.documents
      profile.category
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
      profile.youth_risk_assessment.responses
      profile.youth_risk_assessment.prefill_source
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
      important_events
      timeline_events
      timeline_events.eventable
      timeline_events.to_location
      journeys
      journeys.from_location
      journeys.to_location
    ].freeze

    INCLUDED_FIELDS = {
      allocation: %i[to_location from_location moves_count created_at],
    }.freeze
  end
end
