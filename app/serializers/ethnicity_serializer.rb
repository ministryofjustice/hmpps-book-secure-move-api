# frozen_string_literal: true

class EthnicitySerializer
  include JSONAPI::Serializer

  set_type :ethnicities

  attributes :id, :key, :title, :description, :nomis_code, :disabled_at
end
