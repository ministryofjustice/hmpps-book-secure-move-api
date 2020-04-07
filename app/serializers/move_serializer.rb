# frozen_string_literal: true

class MoveSerializer < ActiveModel::Serializer
  attributes :id, :reference, :status, :updated_at, :created_at, :time_due, :date, :move_type, :additional_information,
             :cancellation_reason, :cancellation_reason_comment, :move_agreed, :move_agreed_by, :date_from, :date_to

  has_one :person, serializer: PersonSerializer
  has_one :from_location, serializer: LocationSerializer
  has_one :to_location, serializer: LocationSerializer, if: -> { object.to_location.present? }
  has_one :prison_transfer_reason, serializer: PrisonTransferReasonSerializer, if: -> { object.prison_transfer_reason.present? }
  has_many :documents, serializer: DocumentSerializer
  has_many :court_hearings, serializer: CourtHearingSerializer

  INCLUDED_ATTRIBUTES = {
    person: %i[first_names last_name date_of_birth assessment_answers indentifiers ethnicity gender reason_comment],
    from_location: %i[location_type description],
    to_location: %i[location_type description],
    documents: %i[url filename filesize content_type],
    prison_transfer_reason: %i[key title],
  }.freeze
end
