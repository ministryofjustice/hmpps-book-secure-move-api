# frozen_string_literal: true

class AllocationComplexCaseSerializer
  include JSONAPI::Serializer

  set_type :allocation_complex_cases

  attributes :id, :key, :title
end
