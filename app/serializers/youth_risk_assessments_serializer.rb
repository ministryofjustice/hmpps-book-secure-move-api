# frozen_string_literal: true

class YouthRiskAssessmentsSerializer
  include JSONAPI::Serializer
  include JSONAPI::ConditionalRelationships

  set_type :youth_risk_assessments

  attribute :status do |object|
    object.status == 'unstarted' ? 'not_started' : object.status
  end
end
