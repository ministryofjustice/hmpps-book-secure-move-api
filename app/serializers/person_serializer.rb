# frozen_string_literal: true

class PersonSerializer < ActiveModel::Serializer
  attributes :id, :first_names, :last_name, :date_of_birth

  def first_names
    object.latest_profile&.first_names
  end

  def last_name
    object.latest_profile&.last_name
  end

  def date_of_birth
    object.latest_profile&.date_of_birth
  end
end
