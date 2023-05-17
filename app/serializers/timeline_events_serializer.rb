# frozen_string_literal: true

class TimelineEventsSerializer
  include JSONAPI::Serializer

  set_type :events

  attributes :occurred_at, :event_type, :classification
end
