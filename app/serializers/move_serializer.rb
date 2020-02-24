# frozen_string_literal: true

class MoveSerializer < ActiveModel::Serializer
  attributes :id, :reference, :status, :updated_at, :time_due, :date, :move_type, :additional_information,
             :cancellation_reason, :cancellation_reason_comment

  has_one :person, serializer: PersonSerializer
  has_one :from_location, serializer: LocationSerializer
  has_one :to_location, serializer: LocationSerializer, if: -> { object.to_location.present? }
  has_many :documents, serializer: DocumentSerializer

  INCLUDED_ATTRIBUTES = {
    person: %i[first_names last_name date_of_birth assessment_answers indentifiers ethnicity gender],
    from_location: %i[location_type description],
    to_location: %i[location_type description],
    documents: %i[url filename filesize content_type],
  }.freeze
end
