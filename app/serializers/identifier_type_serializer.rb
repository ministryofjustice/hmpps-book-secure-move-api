# frozen_string_literal: true

class IdentifierTypeSerializer
  include JSONAPI::Serializer

  set_type :identifier_types

  attributes :key, :title, :description, :disabled_at
end
