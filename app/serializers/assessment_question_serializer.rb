# frozen_string_literal: true

class AssessmentQuestionSerializer < ActiveModel::Serializer
  attributes :id, :key, :category, :title, :disabled_at
end
