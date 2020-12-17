class YouthRiskAssessment < VersionedModel
  include FrameworkAssessmentable

  belongs_to :prefill_source, class_name: 'YouthRiskAssessment', optional: true
  belongs_to :move

  validate :move_from_location

  def self.framework_name
    'youth-risk-assessment'
  end

private

  def previous_assessment
    @previous_assessment ||= profile&.person&.latest_youth_risk_assessment
  end

  def move_from_location
    errors.add(:move, "'from_location' must be from either a secure training centre or a secure children's home") unless move&.from_location&.secure_training_centre? || move&.from_location&.secure_childrens_home? || move&.from_location&.young_offender_institution
  end
end
