# frozen_string_literal: true

class IdentifierTypeSerializer < ActiveModel::Serializer
  attributes :id, :key, :title, :description
end
