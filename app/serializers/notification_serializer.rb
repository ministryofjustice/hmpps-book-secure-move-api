# frozen_string_literal: true

class NotificationSerializer
  include JSONAPI::Serializer

  set_type :notifications

  attributes :event_type

  attribute :timestamp, &:created_at

  belongs_to :move, if: ->(object) { object.move_id }, links: {
    self: ->(object) { Rails.application.routes.url_helpers.api_move_url(object.move_id) },
  }

  belongs_to :person_escort_record, if: ->(object) { object.person_escort_record_id }, links: {
    self: ->(object) { Rails.application.routes.url_helpers.api_person_escort_record_url(object.person_escort_record_id) },
  }

  belongs_to :youth_risk_assessment, if: ->(object) { object.youth_risk_assessment_id }, links: {
    self: ->(object) { Rails.application.routes.url_helpers.api_youth_risk_assessment_url(object.youth_risk_assessment_id) },
  }

  belongs_to :generic_event, if: ->(object) { object.generic_event_id }
end
