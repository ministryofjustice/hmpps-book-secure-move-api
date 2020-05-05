# frozen_string_literal: true

class SupplierSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :name, :key
end
