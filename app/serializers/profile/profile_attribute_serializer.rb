# frozen_string_literal: true

class Profile::ProfileAttributeSerializer < ActiveModel::Serializer
  attributes :description, :comments, :date, :expiry_date, :profile_attribute_type_id

  def initialize; end
end
