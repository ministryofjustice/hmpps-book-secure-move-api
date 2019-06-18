# frozen_string_literal: true

class AssessmentQuestionSerializer < ActiveModel::Serializer
  attributes :id, :key, :category, :title, :nomis_alert_type, :nomis_alert_code
end
