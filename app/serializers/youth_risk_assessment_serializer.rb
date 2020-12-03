# frozen_string_literal: true

class YouthRiskAssessmentSerializer < FrameworkAssessmentSerializer
  belongs_to :profile, serializer: V2::ProfileSerializer
  belongs_to :move, serializer: V2::MoveSerializer

  set_type :youth_risk_assessments

  belongs_to :prefill_source, serializer: YouthRiskAssessmentPrefillSourceSerializer
end
