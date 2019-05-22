# frozen_string_literal: true

class ProfileAttributeTypeSerializer < ActiveModel::Serializer
  attributes :id, :category, :user_type, :description, :alert_type, :alert_code
end
