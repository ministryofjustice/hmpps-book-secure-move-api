# frozen_string_literal: true

class AssessmentAnswerTypeSerializer < ActiveModel::Serializer
  attributes :id, :category, :title, :nomis_alert_type, :nomis_alert_code
end
