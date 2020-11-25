class PersonEscortRecord < VersionedModel
  include FrameworkAssessmentable

  def self.framework_name
    'person-escort-record'
  end

private

  def previous_assessment
    @previous_assessment ||= profile&.person&.latest_person_escort_record
  end
end
