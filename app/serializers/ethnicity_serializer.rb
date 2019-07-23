# frozen_string_literal: true

class EthnicitySerializer < ActiveModel::Serializer
  attributes :id, :key, :title, :description, :nomis_code, :disabled_at
end
