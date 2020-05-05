# frozen_string_literal: true

class FastJsonapi::SupplierSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :name, :key
end
