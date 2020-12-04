# frozen_string_literal: true

class YouthRiskAssessmentSerializer < FrameworkAssessmentSerializer
  # Due to autoloading issues, have mirrored relationships in children classes
  # TODO: when moving off versions, move this back into framework assessment serializer
  belongs_to :profile, serializer: V2::ProfileSerializer
  belongs_to :move, serializer: V2::MoveSerializer

  set_type :youth_risk_assessments

  belongs_to :prefill_source, serializer: YouthRiskAssessmentPrefillSourceSerializer
end
