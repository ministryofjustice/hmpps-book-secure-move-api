# frozen_string_literal: true

class V2::ProfilesSerializer
  include JSONAPI::Serializer
  include JSONAPI::ConditionalRelationships

  set_type :profiles

  attributes :requires_youth_risk_assessment, :assessment_answers

  belongs_to :category, serializer: CategorySerializer
  belongs_to :person, serializer: ::V2::PersonSerializer

  has_one_if_included :person_escort_record, serializer: PersonEscortRecordsSerializer
  has_one_if_included :youth_risk_assessment, serializer: YouthRiskAssessmentsSerializer
end
