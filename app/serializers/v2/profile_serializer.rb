# frozen_string_literal: true

class V2::ProfileSerializer
  include JSONAPI::Serializer

  set_type :profiles

  attributes :assessment_answers

  belongs_to :person, serializer: ::V2::PersonSerializer
  has_many :documents, serializer: DocumentSerializer
  has_one :person_escort_record, serializer: PersonEscortRecordSerializer
  has_one :youth_risk_assessment, serializer: YouthRiskAssessmentSerializer

  SUPPORTED_RELATIONSHIPS = %w[documents person person_escort_record youth_risk_assessment].freeze
end
