class PersonEscortRecord < VersionedModel
  include FrameworkAssessmentable

  belongs_to :prefill_source, class_name: 'PersonEscortRecord', optional: true
  # To support legacy PERs without a move, allow the association to be optional
  belongs_to :move, optional: true

  has_many :medical_events, -> { where(classification: :medical) }, as: :eventable, class_name: 'GenericEvent'
  has_many :incident_events, -> { where(classification: :incident) }, as: :eventable, class_name: 'GenericEvent'

  def self.framework_name
    'person-escort-record'
  end

  def important_events
    medical_events + incident_events + GenericEvent::PerPropertyChange.where(eventable: self)
  end

private

  def previous_assessment
    profile&.person&.latest_person_escort_record
  end
end
