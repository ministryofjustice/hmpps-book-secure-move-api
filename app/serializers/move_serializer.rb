# frozen_string_literal: true

class MoveSerializer < ActiveModel::Serializer
  attributes :id, :type, :status, :updated_at, :time_due, :date

  def type
    object.move_type
  end

  has_one :person, serializer: PersonSerializer
  has_one :from_location, serializer: LocationSerializer
  has_one :to_location, serializer: LocationSerializer
end
