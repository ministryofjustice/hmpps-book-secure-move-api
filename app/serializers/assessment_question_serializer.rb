# frozen_string_literal: true

class AssessmentQuestionSerializer
  include JSONAPI::Serializer

  set_type :assessment_questions

  attributes :id, :key, :category, :title, :disabled_at
end
