# frozen_string_literal: true

class SupplierSerializer
  include JSONAPI::Serializer

  INCLUDED_ATTRIBUTES = [:name, :key]

  set_type :suppliers

  attributes(*INCLUDED_ATTRIBUTES)
end
