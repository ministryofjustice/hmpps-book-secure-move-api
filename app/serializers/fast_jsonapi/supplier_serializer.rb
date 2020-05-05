# frozen_string_literal: true

class FastJsonapi::SupplierSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :key
end
