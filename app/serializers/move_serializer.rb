# frozen_string_literal: true

class MoveSerializer < ActiveModel::Serializer
  attributes :id, :reference, :status, :updated_at, :time_due, :date

  has_one :person, serializer: PersonSerializer
  has_one :from_location, serializer: LocationSerializer
  has_one :to_location, serializer: LocationSerializer

  INCLUDED_OVERVIEW = {
    person: %i[first_names last_name date_of_birth assessment_answers indentifiers],
    from_location: %i[location_type description],
    to_location: %i[location_type description]
  }.freeze

  INCLUDED_DETAIL = INCLUDED_OVERVIEW.deep_merge(
    person: %i[ethnicity gender]
  ).freeze
end
