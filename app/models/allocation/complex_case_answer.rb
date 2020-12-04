# frozen_string_literal: true

class Allocation
  class ComplexCaseAnswer
    include ActiveModel::Model

    attr_accessor(
      :title,
      :answer,
      :allocation_complex_case_id,
      :key,
    )

    validates :allocation_complex_case_id, presence: true

    def empty?
      allocation_complex_case_id.blank?
    end
  end
end
