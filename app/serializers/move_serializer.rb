# frozen_string_literal: true

class MoveSerializer
  include JSONAPI::Serializer

  set_type :moves

  attributes :reference,
             :status,
             :updated_at,
             :created_at,
             :time_due,
             :date,
             :move_type,
             :nomis_event_id,
             :additional_information,
             :rejection_reason,
             :cancellation_reason,
             :cancellation_reason_comment,
             :move_agreed,
             :move_agreed_by,
             :date_from,
             :date_to

  has_one :person
  belongs_to :profile
  belongs_to :from_location, serializer: LocationSerializer
  belongs_to :to_location, serializer: LocationSerializer
  belongs_to :prison_transfer_reason

  has_many :documents do |object|
    object.profile&.documents
  end
  has_many :court_hearings

  belongs_to :allocation
  belongs_to :original_move, serializer: MoveSerializer

  SUPPORTED_RELATIONSHIPS = %w[
    profile.documents
    person.ethnicity
    person.gender
    profile.person.ethnicity
    profile.person.gender
    profile.person_escort_record
    profile.person_escort_record.flags
    profile.person_escort_record.framework
    profile.person_escort_record.prefill_source
    profile.person_escort_record.responses
    profile.person_escort_record.responses.nomis_mappings
    profile.person_escort_record.responses.question
    profile.person_escort_record.responses.question.descendants.**
    from_location
    from_location.suppliers
    to_location
    to_location.suppliers
    documents
    prison_transfer_reason
    court_hearings
    allocation
    original_move
  ].freeze

  INCLUDED_FIELDS = {
    allocations: %i[to_location from_location moves_count created_at],
  }.freeze
end
