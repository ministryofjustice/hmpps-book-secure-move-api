class YouthRiskAssessment < VersionedModel
  include FrameworkAssessmentable

  belongs_to :prefill_source, class_name: 'YouthRiskAssessment', optional: true
  belongs_to :move

  def self.framework_name
    'youth-risk-assessment'
  end

private

  def previous_assessment
    @previous_assessment ||= profile&.person&.latest_youth_risk_assessment
  end
end
