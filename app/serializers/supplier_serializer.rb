# frozen_string_literal: true

class SupplierSerializer
  include JSONAPI::Serializer

  INCLUDED_ATTRIBUTES = %i[name key].freeze

  set_type :suppliers

  attributes(*INCLUDED_ATTRIBUTES)
end
