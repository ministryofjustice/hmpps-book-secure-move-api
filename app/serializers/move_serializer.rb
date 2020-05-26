# frozen_string_literal: true

class MoveSerializer < ActiveModel::Serializer
  attributes :id,
             :reference,
             :status,
             :updated_at,
             :created_at,
             :time_due,
             :date,
             :move_type,
             :additional_information,
             :cancellation_reason,
             :cancellation_reason_comment,
             :move_agreed,
             :move_agreed_by,
             :date_from,
             :date_to

  has_one :person, serializer: PersonSerializer
  has_one :profile, serializer: ProfileSerializer

  has_one :from_location, serializer: LocationSerializer
  has_one :to_location, serializer: LocationSerializer, if: -> { object.to_location.present? }
  has_one :prison_transfer_reason, serializer: PrisonTransferReasonSerializer, if: -> { object.prison_transfer_reason.present? }
  has_many :documents, serializer: DocumentSerializer
  has_many :court_hearings, serializer: CourtHearingSerializer
  belongs_to :allocation, serializer: AllocationSerializer

  SUPPORTED_RELATIONSHIPS = %w[
    profile
    person.ethnicity
    person.gender
    from_location
    to_location
    documents
    prison_transfer_reason
    court_hearings
    allocation
  ].freeze

  INCLUDED_FIELDS = {
    allocation: %i[to_location from_location moves_count created_at],
  }.freeze

  def person
    # TODO: Remove the support for person id in future
    if object.profile_id
      object&.profile&.person
    elsif object.person_id
      Person.find(object.person_id)
    end
  end
end
