# frozen_string_literal: true

class GenderSerializer < ActiveModel::Serializer
  attributes :id, :key, :title, :description, :disabled_at, :nomis_code
end
