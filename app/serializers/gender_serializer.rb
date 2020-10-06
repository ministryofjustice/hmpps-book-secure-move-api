# frozen_string_literal: true

class GenderSerializer
  include JSONAPI::Serializer

  set_type :genders

  attributes :key, :title, :description, :disabled_at, :nomis_code
end
