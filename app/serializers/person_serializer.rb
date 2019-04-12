# frozen_string_literal: true

class PersonSerializer < ActiveModel::Serializer
  attributes :id, :forenames, :surname

  def forenames
    object.latest_profile&.forenames
  end

  def surname
    object.latest_profile&.surname
  end
end
