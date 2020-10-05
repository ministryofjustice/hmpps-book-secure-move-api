# frozen_string_literal: true

class IdentifierTypeSerializer
  include JSONAPI::Serializer

  set_type :identifier_types

  attributes :id, :key, :title, :description, :disabled_at
end
