class PersonEscortRecord < VersionedModel
  include FrameworkAssessmentable

  belongs_to :prefill_source, class_name: 'PersonEscortRecord', optional: true

  def self.framework_name
    'person-escort-record'
  end

  def editable
    return false if confirmed?

    move_status_editable?
  end

private

  def move_status_editable?
    return true if move.blank?

    move.requested? || move.booked?
  end

  def previous_assessment
    @previous_assessment ||= profile&.person&.latest_person_escort_record
  end
end
