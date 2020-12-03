# frozen_string_literal: true

class YouthRiskAssessmentSerializer < FrameworkAssessmentSerializer
  set_type :youth_risk_assessments

  belongs_to :prefill_source, serializer: YouthRiskAssessmentPrefillSourceSerializer
end
