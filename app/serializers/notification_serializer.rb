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

  belongs_to :event, id_method_name: :generic_event_id, serializer: GenericEventSerializer, if: ->(object) { object.generic_event_id }

  belongs_to :lodging, if: ->(object) { object.lodging_id }, links: {
    self: ->(object) { Rails.application.routes.url_helpers.api_move_lodging_url(move_id: object.move_id, id: object.lodging_id) },
  }
end
