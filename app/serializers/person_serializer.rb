# frozen_string_literal: true

class PersonSerializer < ActiveModel::Serializer
  attributes :id, :forenames, :surname, :date_of_birth

  def forenames
    object.latest_profile&.forenames
  end

  def surname
    object.latest_profile&.surname
  end

  def date_of_birth
    object.latest_profile&.date_of_birth
  end
end
