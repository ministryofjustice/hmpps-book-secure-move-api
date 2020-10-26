# frozen_string_literal: true

class SupplierSerializer
  include JSONAPI::Serializer

  set_type :suppliers

  attributes :name, :key
end
